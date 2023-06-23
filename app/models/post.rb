class Post < ApplicationRecord
  belongs_to :user
  belongs_to :place
  has_many :comments
  has_many :favourites

  validates :video_url, presence: true
  validates :video_public_id, presence: true
end
