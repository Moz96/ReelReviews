class Place < ApplicationRecord
  has_many :posts
  has_many :favourites, class_name: 'Favourite', dependent: :destroy

  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?
end
