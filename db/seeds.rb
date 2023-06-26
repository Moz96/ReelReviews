require 'openai'
require 'net/http'
require 'json'

open_ai_client = OpenAI::Client.new(access_token: ENV['OPENAI_ACCESS_TOKEN'])

def create_users
  User.create(
    email: 'tommagrath95@gmail.com',
    username: 'Tom',
    password: 'password'
    )
  puts 'Created User Tom'

  User.create(
    email: 'w.janic94@gmail.com',
    username: 'Woj',
    password: 'password'
  )
  puts 'Created User Woj'

  User.create(
    email: 'charliemorris.96@gmail.com',
    username: 'Moz',
    password: 'password'
  )
  puts 'Created User Moz'

  User.create(
    email: 'nicholas@nicholashennellfoley.com',
    username: 'Nick',
    password: 'password'
  )
  puts 'Created User Nick'

  puts 'Created All Users'
end

create_users

def list_cloudinary_videos(current_place)
  Cloudinary::Api.resources(
    resource_type: :video,
    type: :upload,
    prefix: "#{current_place}/"
  )['resources']
end

def add_posts(place, current_place, users)
  videos = list_cloudinary_videos(current_place)
  videos.each_with_index do |video, k|
    Post.create(
      user_id: users.sample.id,
      place_id: place.id,
      place_rating: rand(1..5),
      video_url: video['url'],
      video_public_id: video['public_id']
    )
    puts "Saved Post #{k + 1} of #{videos.size} to #{place.name}"
  end
end

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

users = User.all

# Get place folders from Cloudinary that contain videos, only dev environment
user_folders = Cloudinary::Api.subfolders('development', options = {})['folders']
google_place_id_extraction_regex = /- (.+)/

# Easier to us the gem for getting most details
google_places_gem_client = GooglePlaces::Client.new(ENV['GOOGLE_PLACES_API'])

# Open AI prompt for matching categories
open_ai_user_message = 'You are given two pieces of information:
                        A single place type sent from the google places api, and the name of the place.
                        Please use both pieces of information to output the closest matching category from this list:
                        Culture, Food, Bars, Outdoors, Cafés, Fitness.
                        You only ever output a single category and no other text.'

user_folders.each_with_index do |user_folder, user_index|
  place_folders = Cloudinary::Api.subfolders("development/#{user_folder['name']}", options = {})['folders']
  place_folders.each_with_index do |place_folder, place_index|
    puts "Creating Place #{place_index + 1} of #{place_folders.size}"

    # Get the place details from the API, using the Google Place ID extracted from the folder name
    google_place_id = place_folder['name'][google_place_id_extraction_regex, 1]
    gem_place_details = google_places_gem_client.spot(google_place_id)

    url = URI("https://maps.googleapis.com/maps/api/place/details/json?fields=editorial_summary%2Cwebsite%2Copening_hours&place_id=#{google_place_id}&key=#{ENV['GOOGLE_PLACES_API']}")

    # Details not returned by the gem
    direct_api_place_details = JSON.parse(Net::HTTP.get(url))['result']

    response = open_ai_client.chat(
      parameters: {
        model: 'gpt-4',
        messages: [{ role: 'user', content: open_ai_user_message +
                                            "Google Place type: #{gem_place_details.types[0]}" +
                                            "Place name: #{gem_place_details.name}"}],
        temperature: 1
      }
    )

    place = Place.create(
      name: gem_place_details.name,
      description: direct_api_place_details['editorial_summary'] ? direct_api_place_details['editorial_summary']['overview'] : nil,
      address: gem_place_details.formatted_address,
      url: direct_api_place_details['website'],
      latitude: gem_place_details.lat,
      longitude: gem_place_details.lng,
      # Need a separate API call to get the place photo
      image_url: gem_place_details.photos[0].fetch_url(800),
      category: response.dig("choices", 0, "message", "content"),
      opening_hours: concatenate_opening_hours(direct_api_place_details['opening_hours']),
      google_place_id: google_place_id
    )

    add_posts(place, "development/#{user_folder['name']}/#{place_folder['name']}", users)
  end
end
