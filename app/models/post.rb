class Post < ApplicationRecord
  belongs_to :user
  belongs_to :place
  has_many :comments

  validates :video_url, presence: true
  validates :video_public_id, presence: true

  accepts_nested_attributes_for :place
end
