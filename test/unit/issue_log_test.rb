require File.expand_path('../../test_helper', __FILE__)

class IssueLogTest < ActiveSupport::TestCase
  fixtures :users, :projects, :trackers, :issue_statuses, :projects_trackers, :enumerations

  def build_issue
    Issue.new(subject: 'Test subject',
      project_id: Project.first,
      tracker: Tracker.first,
      status: IssueStatus.first,
      author: User.first,
      priority: IssuePriority.first)
  end

  def test_should_create_one_issue_log_without_given_start_date_and_estimated_hours
    issue = build_issue
    assert_difference 'Issue.count', +1 do
      assert_difference 'IssueLog.count', +1 do
        assert issue.save
        log = issue.issue_logs.first
        assert_equal 0, log.time
        assert_equal issue.created_on.to_date, log.date
      end
    end
  end

  def test_should_create_multiple_issue_logs_with_given_start_date_and_estimated_hours_in_week
    issue = build_issue
    assert_difference 'Issue.count', +1 do
      assert_difference 'IssueLog.count', +5 do
        date = Date.parse('27/07/2015')
        issue.start_date = date
        issue.estimated_hours = 35

        assert issue.save

        d1, d2, d3, d4, d5 = issue.issue_logs.order('date').to_a

        assert_equal 480, d1.time
        assert_equal date, d1.date

        assert_equal 480, d2.time
        assert_equal date + 1, d2.date

        assert_equal 480, d3.time
        assert_equal date + 2, d3.date

        assert_equal 480, d4.time
        assert_equal date + 3, d4.date

        assert_equal 180, d5.time
        assert_equal date + 4, d5.date
      end
    end
  end

  def test_should_create_multiple_issue_logs_with_given_start_date_and_estimated_hours_including_weekend
    issue = build_issue
    assert_difference 'Issue.count', +1 do
      assert_difference 'IssueLog.count', +5 do
        date = Date.parse('29/07/2015')
        issue.start_date = date
        issue.estimated_hours = 35

        assert issue.save

        d1, d2, d3, d4, d5 = issue.issue_logs.order('date').to_a

        assert_equal 480, d1.time
        assert_equal date, d1.date

        assert_equal 480, d2.time
        assert_equal date + 1, d2.date

        assert_equal 480, d3.time
        assert_equal date + 2, d3.date

        assert_equal 480, d4.time
        assert_equal date + 5, d4.date

        assert_equal 180, d5.time
        assert_equal date + 6, d5.date
      end
    end
  end

  def test_should_create_multiple_issue_logs_with_given_start_date_and_estimated_hours_including_holidays
    issue = build_issue
    assert_difference 'Issue.count', +1 do
      assert_difference 'IssueLog.count', +2 do
        date = Date.parse('24/12/2015')
        issue.start_date = date
        issue.estimated_hours = 16

        assert issue.save

        d1, d2 = issue.issue_logs.order('date').to_a

        assert_equal 480, d1.time
        assert_equal date, d1.date

        assert_equal 480, d2.time
        assert_equal date + 4, d2.date

      end
    end
  end
end
