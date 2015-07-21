class TaskManagerController < ApplicationController
  unloadable
  helper :sort
  include SortHelper

  def index
    @issues = Issue.all
    @members = Member.all

    sort_init 'issues.id', 'asc'
    sort_update %w(issues.tracker issues.subject issues.estimated_hours issues.assigned_to issues.id)

  end

end
