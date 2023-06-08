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

place = Place.create(
  name: "Test name",
  address: "Test address",
  description: "Test description",
  category: "Test category",
  url: "https://example.com",
  opening_hours: "10am - 5pm"
)

post1 = Post.new(
  user_id: user.id,
  place_id: place.id,
  place_rating: 5
)
post1.reel.attach(io: File.open('app/assets/videos/testreel1.mp4'), filename: 'testreel1.mp4', content_type: 'video/mp4')
post1.save

post2 = Post.new(
  user_id: user.id,
  place_id: place.id,
  place_rating: 5
)
post2.reel.attach(io: File.open('app/assets/videos/testreel2.mp4'), filename: 'testreel1.mp4', content_type: 'video/mp4')
post2.save
