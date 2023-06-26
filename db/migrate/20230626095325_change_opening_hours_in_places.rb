class ChangeOpeningHoursInPlaces < ActiveRecord::Migration[7.0]
  def change
    change_column :places, :opening_hours, :string
  end
end
