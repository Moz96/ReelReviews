class FavouritesController < ApplicationController
  def index
    @places = Place.all
  end
end
