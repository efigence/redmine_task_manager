require File.expand_path('../../test_helper', __FILE__)

class MemberTest < ActiveSupport::TestCase

  def setup
    @member = Member.new(:project_id => 1, :user_id => 4, :role_ids => [8])
    @member.save
  end

  def test_should_update_member_with_hours_per_day
    @member.hours_per_day = 6
    @member.save

    assert_equal 6.0, @member.hours_per_day
  end

end
