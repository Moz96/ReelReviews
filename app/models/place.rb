class Place < ApplicationRecord
  has_many :posts
  has_many :favourites, dependent: :destroy
  has_one_attached :image

  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?
end
