class PlacesController < ApplicationController
  before_action :set_place, only: [:show]
  def index
    @places = Place.all
  end

  def new
    @place = Place.new
  end

  def create
    @place = Place.new(place_params)
    if @place.save!
      redirect_to places_path
    else
      flash.now[:alert] = 'Location could not be created'
      render :new
    end
  end

  def show
    @posts = places.posts
  end

  private

  def place_params
    params.require(:place).permit
  end

  def set_place
    @place = Place.find_by(params[:id])
  end
end
