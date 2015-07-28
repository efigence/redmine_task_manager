class CreateIssueLogs < ActiveRecord::Migration
  def self.up
    create_table :issue_logs do |t|
      t.integer :issue_id
      t.integer :project_id
      t.integer :user_id
      t.date :date
      t.integer :time
    end
    add_index :issue_logs, [:user_id, :date]
  end

  def self.down
    drop_table :issue_logs
  end

end
