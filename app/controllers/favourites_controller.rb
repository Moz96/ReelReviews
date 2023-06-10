class FavouritesController < ApplicationController
  before_action :authenticate_user!

  def index
    @places = current_user.favourites.map(&:place)
  end


  def create
    place = Place.find(params[:place_id])
    @favourite = Favourite.new(user_id: current_user.id, place_id: place.id)
    if @favourite.save
      redirect_to favourites_path
    else 
      render :places, status: :unprocessable_entity
    end 
  
  end


  def destroy
    place = Place.find(params[:place_id])
    current_user.favourites.find_by(place_id: place.id).destroy
    redirect_to favourites_path
  end

end 