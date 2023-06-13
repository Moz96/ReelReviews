class AddVideoDetailsToPosts < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :video_url, :string
    add_column :posts, :video_public_id, :string
  end
end
