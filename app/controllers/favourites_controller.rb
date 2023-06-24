class FavouritesController < ApplicationController
  def index
    @places = current_user.favourites.map(&:place)
  end

  def create
    place = Place.find(params[:place_id])
    favourite = current_user.favourites.find_by(place_id: place.id)

    if favourite.nil?
      @favourite = current_user.favourites.build(place: place)
      if @favourite.save
        redirect_to place_path(place), notice: 'Place added to favorites.'
      else
        redirect_to place_path(place), alert: 'Failed to add place to favorites.'
      end
    else
      favourite.destroy
      redirect_to place_path(place), notice: 'Place removed from favorites.'
    end
  end

  def destroy
    favourite = current_user.favourites.find(params[:id])
    place = favourite.place
    favourite.destroy
    redirect_to place_path(place), notice: 'Place removed from favorites.'
  end
end
