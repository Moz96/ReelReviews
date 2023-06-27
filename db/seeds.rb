require_relative '../lib/create_place_helper'

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

users = User.all

# Get place folders from Cloudinary that contain videos, only dev environment
user_folders = Cloudinary::Api.subfolders('development', options = {})['folders']
google_place_id_extraction_regex = /- (.+)/

user_folders.each_with_index do |user_folder, user_index|
  puts "Processing user #{user_index + 1} of #{user_folder.size} (#{user_folder['name']})"
  place_folders = Cloudinary::Api.subfolders("development/#{user_folder['name']}", options = {})['folders']
  place_folders.each_with_index do |place_folder, place_index|
    puts "Creating Place #{place_index + 1} of #{place_folders.size} places from #{user_folder['name']}"

    # Get the place details from the API, using the Google Place ID extracted from the folder name
    google_place_id = place_folder['name'][google_place_id_extraction_regex, 1]

    place = create_place_helper(google_place_id)

    add_posts(place, "development/#{user_folder['name']}/#{place_folder['name']}", users)
  end
end
