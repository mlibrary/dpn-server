# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

class BagsController < ApplicationController
  include Authenticate
  include Pagination
  include Adaptation

  local_node_only :create, :update, :destroy
  uses_pagination :index
  adapt!

  def index
    @bags = Bag.updated_after(params[:after])
      .updated_before(params[:before])
      .with_admin_node(params[:admin_node])
      .with_ingest_node(params[:ingest_node])
      .with_member(params[:member])
      .with_bag_type(params[:type])
      .replicated_by(params[:replicating_nodes])
      .order(parse_ordering(params[:order_by]))
      .page(@page)
      .per(@page_size)

    render "bags/index", status: 200
  end


  def show
    @bag = Bag.find_by_uuid!(params[:uuid])
    render "shared/show", status: 200
  end


  def create
    if Bag.find_by_uuid(params[:uuid]).present?
      render nothing: true, status: 409 and return
    else
      @bag = case params[:type]
      when DataBag.to_s
        DataBag.new
      when RightsBag.to_s
        RightsBag.new
      when InterpretiveBag.to_s
        InterpretiveBag.new
      else
        Bag.new
      end
      if @bag.update_with_associations(params)
        render "shared/create", status: 201
      else
        render "shared/errors", status: 400
      end
    end
  end


  def update
    @bag = Bag.find_by_uuid!(params[:uuid])

    if @bag.update_with_associations(params)
      render "shared/update", status: 200
    else
      render "shared/errors", status: 400
    end
  end


  def destroy
    bag = Bag.find_by_uuid!(params[:uuid])
    bag.destroy!
    render nothing: true, status: 204
  end

end
