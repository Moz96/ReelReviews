class Post < ApplicationRecord
  belongs_to :user
  belongs_to :place
  has_many :comments
  has_one_attached :reel
end
