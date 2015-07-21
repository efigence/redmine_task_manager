require File.expand_path('../../test_helper', __FILE__)

class AccessRightsTest < Redmine::IntegrationTest
  self.fixture_path = File.join(File.dirname(__FILE__), '../fixtures')

  fixtures :users, :settings, :groups_users

  def setup
    User.current = nil
  end

  def test_not_permitted_group_should_be_redirected_from_task_manager_path
    log_user('jsmith', 'jsmith')
    get task_manager_path
    assert_response :redirect
    assert_redirected_to home_path
  end

  def test_permitted_group_should_see_task_manager_path
    log_user('dlopper', 'foo')
    get task_manager_path
    assert_response :success
    assert_select '#date'
  end

end
