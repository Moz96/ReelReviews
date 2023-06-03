class CreatePlaces < ActiveRecord::Migration[7.0]
  def change
    create_table :places do |t|
      t.string :name
      t.string :address
      t.string :description
      t.string :category
      t.string :url
      t.time :opening_hours

      t.timestamps
    end
  end
end
