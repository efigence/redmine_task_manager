require File.expand_path('../../test_helper', __FILE__)

class AccountTest < Redmine::IntegrationTest
  fixtures :projects,
           :users, :email_addresses,
           :roles,
           :members,
           :member_roles,
           :trackers,
           :projects_trackers,
           :enabled_modules,
           :issue_statuses,
           :issues,
           :enumerations,
           :custom_fields,
           :custom_values,
           :custom_fields_trackers

  def setup
    log_user("jsmith", "jsmith")
    @issue = Issue.new
    @issue.subject = "Testing start_time"
    @issue.project_id = 1
    @issue.tracker_id = 1
    @issue.author_id = 1
    @issue.status_id = 1
  end

  def test_new_issue_should_fetch_start_time
    get '/projects/ecookbook/issues/new'
    assert_response :success
    assert_select '#issue_start_time'
  end

  def test_issues_should_fetch_start_time
    get '/issues/1'
    assert_response :success
    assert_select '.start-time'
  end

  def test_should_create_issue_with_proper_start_time_format
    assert_difference 'Issue.count', +1 do
      @issue.start_time = '15:00'
      @issue.save
    end

    assert_equal '03:00 PM', @issue.start_time.strftime("%I:%M %p")
  end

  def test_should_create_issue_without_start_time
    assert_difference 'Issue.count', +1 do
      @issue.save
    end
  end

end
