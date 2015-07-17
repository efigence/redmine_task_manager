class AddStartTimeToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :start_time, :time, null: true
  end
end
