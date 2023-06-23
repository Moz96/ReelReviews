class Place < ApplicationRecord
  has_many :posts
  has_many :favourites, dependent: :destroy
  belongs_to :user

  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?
end
