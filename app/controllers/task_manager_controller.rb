class TaskManagerController < ApplicationController
  unloadable

  helper :sort
  include SortHelper

  before_filter :check_access

  def index
    @issues = Issue.all
    @members = Member.all

    sort_init 'issues.id', 'asc'
    sort_update %w(issues.tracker issues.subject issues.estimated_hours issues.assigned_to issues.id)

  end

  private
  def check_access
    unless User.current.admin? || User.current.has_task_manager_access?
      redirect_to home_path
    end
  end

end
