class Glance::BagsController < ApplicationController

  def index
    @grid = BagsGrid.new(params[:bags_grid]) do |scope|
      scope.page(params[:page])
    end
  end

end

