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
                            users.firstname
                            users.lastname
                            members.hours_per_day)

    case params[:format]
    when 'xml', 'json'
      @offset, @limit = api_offset_and_limit
    else
      @limit = per_page_option
    end

    scope = Issue.open.dated(Date.today).joins("INNER JOIN trackers ON issues.tracker_id = trackers.id")
                  .joins("INNER JOIN projects ON issues.project_id = projects.id")
                  .joins("LEFT JOIN users ON issues.assigned_to_id = users.id")
                  .joins("LEFT JOIN members ON issues.assigned_to_id = members.user_id")
    scope = scope.where(project_id: params[:project_id]) if params[:project_id].present?
    scope = scope.where(assigned_to_id: params[:user_id]) if params[:user_id].present?

    if params[:group_id].present?
      users = User.joins(:groups).where('users_groups_users_join.group_id = ?', params[:group_id]).pluck(:id)
      scope = scope.where(assigned_to_id: users)
    end

    @issue_count = scope.count
    @issue_pages = Paginator.new @issue_count, @limit, params['page']
    @offset ||= @issue_pages.offset
    @issues =  scope.order(sort_clause).limit(@limit).offset(@offset).to_a
    @unassigned_issues = scope.where(assigned_to_id: nil).order(sort_clause).limit(@limit).offset(@offset).to_a

    @members = Member.all
    @projects = Project.all.sort_by(&:name)
    @users = User.all.sort_by(&:firstname)
    @groups = Group.all.sort_by(&:lastname)

  end

  private
  def check_access
    unless User.current.admin? || User.current.has_task_manager_access?
      redirect_to home_path
    end
  end

end
