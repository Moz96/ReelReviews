require_relative 'open_ai_place_category_selector'
require 'net/http'
require 'json'

def create_place_helper(google_place_id)
  google_places_gem_client = GooglePlaces::Client.new(ENV['GOOGLE_PLACES_API'])

  def concatenate_opening_hours(opening_hours)
    if opening_hours
      days = opening_hours['weekday_text']
      concatenated_text = ''
      days.each_with_index do |day, current_day|
        concatenated_text += current_day == days.size - 1 ? day.to_s : "#{day}\n"
      end
      concatenated_text
    else
      'No listed regular opening hours.'
    end
  end

  def create_place(place_details, google_place_id, place_image_url)
    Place.create(
    name: place_details['name'],
    description: place_details['editorial_summary'] ? place_details['editorial_summary']['overview'] : 'No description available.',
    address: place_details['formatted_address'],
    url: place_details['website'],
    latitude: place_details["geometry"]["location"]["lat"],
    longitude: place_details["geometry"]["location"]['lng'],
    # Need a separate API call to get the place photo
    image_url: place_image_url,
    category: ai_select_category(place_details['types'][0], place_details['name']),
    opening_hours: concatenate_opening_hours(place_details['opening_hours']),
    google_place_id: google_place_id
    )
  end

  def get_google_place_details(google_place_id, google_places_gem_client)
    # Using the gem because fetching photo is easier, otherwise in future can use info passed from autcomplete for non-seeded posts

    place_details = google_places_gem_client.spot(google_place_id)
    place_image_url = place_details.photos[0].fetch_url(800)
    place_details = place_details.json_result_object



    # puts "get_google_place_details: #{place_details.name}, #{place_details.place_image_url}"

    # # Google Places API for Details not returned by the gem
    # google_places_api_url = URI("https://maps.googleapis.com/maps/api/place/details/json?fields=editorial_summary%2Cwebsite%2Copening_hours&place_id=#{google_place_id}&key=#{ENV['GOOGLE_PLACES_API']}")
    # direct_api_place_details = JSON.parse(Net::HTTP.get(google_places_api_url))['result']

    create_place(place_details, google_place_id, place_image_url)
  end

  get_google_place_details(google_place_id, google_places_gem_client)
end
