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
    name: "Place #{i + 1}",
    address: "Adress #{i + 1}",
    description: "Description #{i + 1}",
    category: "Test Category",
    url: "https://example.com",
    opening_hours: "10am - 5pm"
  )
  puts "adding image to place"
  place.image.attach(
    io: File.open("app/assets/images/placeimage#{i + 1}.jpg"),
    filename: "placeimage#{i + 1}.jpg",
    content_type: 'image/jpeg'
  )

  3.times do |j|
    puts "creating #{j + 1} of 3 posts"
    post = Post.new(
      user_id: user.id,
      place_id: place.id,
      place_rating: 5
    )
    puts "adding video to post"

    video_path = "app/assets/videos/place_#{i + 1}_video_#{j + 1}.mp4"
    cloudinary_response = Cloudinary::Uploader.upload(video_path, resource_type: "video")

    post.video_url = cloudinary_response["secure_url"]
    post.video_public_id = cloudinary_response["public_id"]

    post.save
  end
end
