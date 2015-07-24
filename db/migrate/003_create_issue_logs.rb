class CreateIssueLogs < ActiveRecord::Migration
  def self.down
    create_table :issue_logs do |t|
      t.integer :issue_id
      t.integer :project_id
      t.integer :user_id
      t.float :time
    end
    add_index :issue_logs, :issue_id
    add_index :issue_logs, :project_id
    add_index :issue_logs, :user_id

  Issue.all.each {|i|
    j = IssueLog.new(:issue_id => i.id, :project_id => i.project_id, :user_id => i.assigned_to_id, :time => i.estimated_hours)
    j.save
  }

  def self.up
    drop_table :issue_logs
  end

end
