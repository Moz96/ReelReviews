# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

require 'faker'
require 'ruby-progressbar'

def colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end

green = 32
yellow = 33
blue = 34

total_steps = 5 + (5 * 3)  # 5 users, 5 places, and 3 posts per place
progress_bar = ProgressBar.create(title: colorize(' Initializing', blue), total: total_steps, format: '%t%B|%c/%C')

5.times do |i|
  User.create(
    email: "user#{i + 1}@example.com",
    username: Faker::Internet.username,
    password: 'password'
  )
  progress_bar.title = colorize(" Created User #{i + 1}", yellow)
  progress_bar.increment
end

progress_bar.title = colorize(' Created All Users', green)

users = User.all

5.times do |j|
  progress_bar.title = colorize(" Creating Place #{j + 1} of 5", yellow)
  place = Place.create(
    name: "Place #{j + 1}",
    address: "Abbey Road #{j + 1}",
    description: "Description #{j + 1}",
    category: case j
              when 0
                'Culture'
              when 1
                'Bars'
              when 2
                'Bars'
              when 3
                'Culture'
              when 4
                'Fitness'
              end,
    url: 'https://example.com',
    opening_hours: '10am - 5pm'
  )
  progress_bar.increment

  progress_bar.title = colorize(" Adding Image to Place #{j + 1}", yellow)
  place.image.attach(
    io: File.open("app/assets/images/placeimage#{j + 1}.jpg"),
    filename: "placeimage#{j + 1}.jpg",
    content_type: 'image/jpeg'
  )

  3.times do |k|
    progress_bar.title = colorize(" Adding Post #{k + 1} of 3 to Place #{j + 1}", yellow)
    post = Post.new(
      user_id: users.sample.id,
      place_id: place.id,
      place_rating: rand(1..5)
    )

    progress_bar.title = colorize(' Uploading Video...', yellow)

    video_path = "app/assets/videos/place_#{j + 1}_video_#{k + 1}.mp4"
    cloudinary_response = Cloudinary::Uploader.upload(video_path, resource_type: 'video')

    post.video_url = cloudinary_response['secure_url']
    post.video_public_id = cloudinary_response['public_id']

    post.save
    progress_bar.increment
    progress_bar.title = colorize(" Uploaded Video and Saved Post #{k + 1} of 3", green)
  end
end
