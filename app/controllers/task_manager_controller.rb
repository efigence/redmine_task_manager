class TaskManagerController < ApplicationController

  helper :sort
  include SortHelper

  before_filter :check_access

  def index
    sort_init 'issues.id', 'asc'
    sort_update %w(issues.id
                            projects.name
                            trackers.name
                            issues.subject
                            issues.estimated_hours
                            issues.start_date
                            users.firstname
                            users.lastname
                            members.hours_per_day)

    @members = Member.all
    @projects = Project.all.sort_by(&:name)
    @users = User.all.sort_by(&:firstname)
    @groups = Group.all.sort_by(&:lastname)
    @project = Project.where(id: params[:project_id]).first if params[:project_id].present?
    @unassigned_issues = @project.issues.open.where(assigned_to_id: nil) if params[:project_id].present?
    @users = User.where(id: params[:user_id]) if params[:user_id].present?
    @issues = Issue.open.where("project_id = ?", @project.id) if params[:project_id].present?

  end

  private
  def check_access
    unless User.current.admin? || User.current.has_task_manager_access?
      redirect_to home_path
    end
  end

end
