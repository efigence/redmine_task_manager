class TaskManagerController < ApplicationController

  helper :sort
  include SortHelper

  before_filter :check_access

  def index
    sort_init 'issues.id', 'asc'
    sort_update %w(issues.tracker issues.subject issues.estimated_hours issues.assigned_to issues.id)

    @members = Member.all
    @projects = Project.joins("JOIN issues ON issues.project_id = projects.id")
    @users = User.joins("JOIN issues ON issues.assigned_to_id = users.id")
    @groups = Group.all

    case params[:format]
    when 'xml', 'json'
      @offset, @limit = api_offset_and_limit
    else
      @limit = per_page_option
    end

    scope = Issue.open
    scope = scope.where(project_id: params[:project_id]) if params[:project_id].present?
    # scope = scope.where(group_id: params[:group_id]) if params[:group_id].present?
    # scope = scope.where(user_id: params[:user_id]) if params[:user_id].present?

    @issue_count = scope.count
    @issue_pages = Paginator.new @issue_count, @limit, params['page']
    @offset ||= @issue_pages.offset
    @issues =  scope.order(sort_clause).limit(@limit).offset(@offset).to_a

  end

  private
  def check_access
    unless User.current.admin? || User.current.has_task_manager_access?
      redirect_to home_path
    end
  end

end
