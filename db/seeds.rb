# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Cloudinary::Uploader.upload("app/assets/images/placeimage1.jpg", options = { asset_folder: "seed/Place 1 - Culture" })
# puts "Uploaded"

require 'faker'

5.times do |i|
  User.create(
    email: "user#{i + 1}@example.com",
    username: Faker::Internet.username,
    password: 'password'
  )
  puts "Created User #{i + 1}"
end

puts 'Created All Users'

users = User.all

def list_cloudinary_images(category, current_place)
  Cloudinary::Api.resources(
    type: :upload,
    prefix: "seed/Place #{current_place} - #{category}/"
  )['resources']
end

def list_cloudinary_videos(category, current_place)
  Cloudinary::Api.resources(
    resource_type: :video,
    type: :upload,
    prefix: "seed/Place #{current_place} - #{category}/"
  )['resources']
end


def add_posts(place, current_place, users)
  videos = list_cloudinary_videos(place.category, current_place)
  videos.each_with_index do |video, k|
    Post.create(
      user_id: users.sample.id,
      place_id: place.id,
      place_rating: rand(1..5),
      video_url: video['url'],
      video_public_id: video['public_id']
    )
    puts "Saved Post #{k + 1} of #{videos.size} to Place #{current_place}"
  end
end

5.times do |j|
  current_place = j + 1
  puts "Creating Place #{current_place} of 5"
  place = Place.new(
    name: "Place #{current_place}",
    address: case current_place
             when 1
               'Barbican Centre, Silk St, Barbican, London, EC2Y 8DS'
             when 2
               'Nightjar, 129 City Rd, London, EC1V 1JB'
             when 3
               '58 Old St, London, EC1V 9AJ'
             when 4
               'Fisherman\'s Bastion, Budapest, 1014, Hungary'
             when 5
               'Marina Bay Sands Singapore, 10 Bayfront Ave, Singapore, 018956'
             end,
    description: "Description #{current_place}",
    category: case current_place
              when 1
                'Culture'
              when 2
                'Bars'
              when 3
                'Bars'
              when 4
                'Culture'
              when 5
                'Outdoors'
              end,
    url: 'https://example.com',
    opening_hours: '10am - 5pm',
  )
  place.image_url = list_cloudinary_images(place.category, current_place)[0]['url']
  place.save

  add_posts(place, current_place, users)
end
