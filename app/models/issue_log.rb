class IssueLog < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes

  belongs_to :issue

  safe_attributes 'issue_id',
    'project_id',
    'user_id',
    'date',
    'time'



end
