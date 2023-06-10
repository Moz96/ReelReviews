class Place < ApplicationRecord
  has_many :posts
  has_many :favourites, dependent: :destroy
  has_one_attached :image
end
