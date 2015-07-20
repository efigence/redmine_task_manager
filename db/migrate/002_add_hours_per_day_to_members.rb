class AddHoursPerDayToMembers < ActiveRecord::Migration
  def change
    add_column :members, :hours_per_day, :float, null: true
  end
end
