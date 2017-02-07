class Glance::ReplicationFlowsController < ApplicationController

  def index
    @grid = ReplicationFlowsGrid.new(params[:replication_flows_grid]) do |scope|
      scope.page(params[:page])
    end
  end

end

