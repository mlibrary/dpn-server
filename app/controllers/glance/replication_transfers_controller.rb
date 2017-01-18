class Glance::ReplicationTransfersController < ApplicationController

  def index
    @grid = ReplicationTransfersGrid.new(params[:replication_transfers_grid]) do |scope|
      scope.page(params[:page])
    end
  end

end

