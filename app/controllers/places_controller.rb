class PlacesController < ApplicationController
  before_action :set_place, only: [:show]
  skip_before_action :authenticate_user!, only: %i[index map show]


  def index
    @categories = ['Popular', 'Culture', 'Restaurants', 'Bars', 'Outdoors', 'Late Night', 'Cafés', 'Fitness']

    # Sorts places by number of likes. The - before place.farouvites denotes descending order.
    popular_places = Place.includes(:favourites).sort_by { |place| -place.favourites.size }

    @places = if params[:category] == 'Popular'
                popular_places
              elsif params[:category]
                Place.where(category: params[:category]).includes(:posts).all
              else
                popular_places
              end
  end

  def map
    @places = Place.all
    @markers = @places.geocoded.map do |place|
      {
        lat: place.latitude,
        lng: place.longitude,
        info_window_html: render_to_string(partial: "places/info_window",  locals: {place: place})
      }
    end
  end

  def new
    @place = Place.new
  end

  def create
    @place = Place.new(place_params)
    @place.user = current_user
    if @place.save!
      redirect_to places_path
    else
      flash.now[:alert] = 'Location could not be created'
      render :new
    end
  end

  def show
    @posts = @place.posts.includes(:comments)
  end


  private

  def place_params
    params.require(:place).permit(:name, :address, :description, :category, :url, :opening_hours)
  end

  def set_place
    @place = Place.find(params[:id])
  end
end
