# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

user = User.create(
  email: "user1@example.com",
  password: "password"
)
puts "creating 5 places"
5.times do |i|
  place = Place.create(
    name: "Place #{i}",
    address: "Adress #{i}",
    description: "Description #{i}",
    category: "Test Category",
    url: "https://example.com",
    opening_hours: "10am - 5pm"
  )
  puts "adding image to place"
  place.image.attach(
    io: File.open("app/assets/images/placeimage#{i}.jpg"),
    filename: "placeimage#{i}.jpg",
    content_type: 'image/jpeg'
  )

  3.times do |j|
    puts "creating #{j} of 3 posts"
    post = Post.new(
      user_id: user.id,
      place_id: place.id,
      place_rating: 5
    )
    puts "adding video to post"
    post.video.attach(
      io: File.open("app/assets/videos/place_#{i}_video#{j}.mp4"),
      filename: "place_#{i}_video#{j}.mp4",
      content_type: 'video/mp4'
    )
    post.save
  end
end
