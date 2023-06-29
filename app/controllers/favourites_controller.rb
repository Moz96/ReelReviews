class FavouritesController < ApplicationController
  def index
    @places = current_user.favourites.map(&:place)
  end

 def create
  place = Place.find(params[:place_id])
  favourite = Favourite.find_by(place_id: place.id)

  if favourite.nil? 
    @favourite = Favourite.new(user_id: current_user.id, place_id: place.id)
    if @favourite.save
      redirect_to favourites_path
    else 
      render :places, status: :unprocessable_entity
    end 
  else
    favourite.destroy
    redirect_to favourites_path
  end
end

  def destroy
    favourite = Favourite.find(params[:id])
    favourite.destroy
  end
end
