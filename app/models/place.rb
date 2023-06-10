class Place < ApplicationRecord
  has_many :posts
  has_many :favourites
  has_one_attached :image
end
