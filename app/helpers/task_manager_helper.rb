module TaskManagerHelper

  def assignees_hours_per_day(issue)
    member = Member.where(user_id: issue.assigned_to_id).first
    member.hours_per_day if member != nil && member.hours_per_day
  end

  def issue_assigned_to_firstname(issue)
    if issue.assigned_to
      issue.assigned_to.firstname
    else
      ' This task is not assigned.'
    end
  end

  def issue_assigned_to_lastname(issue)
    if issue.assigned_to
      issue.assigned_to.lastname
    else
      ' This task is not assigned.'
    end
  end

  def has_unassigned_issues?
    @issues.map(&:assigned_to_id).include? nil
  end

  def has_overbooked_members?
    false
  end

  def has_underbooked_members?
    false
  end

  def member_issues(member)
    Issue.open.dated(Date.today).where("project_id = ? AND assigned_to_id = ?", 1, member.user_id).count
  end

  def member_issues_time(member)
    estimated_time = 0
    Issue.open.dated(Date.today).where("project_id = ? AND assigned_to_id = ?", 1, member.user_id).each do |i|
      estimated_time += i.estimated_hours if i.estimated_hours
    end
    estimated_time
  end

  # super time
  def super_time(issue)

    return unless issue.estimated_hours && issue.start_date && !Member.where(user_id: issue.assigned_to_id).empty?

    @time_left = issue.estimated_hours
    @member_hours = Member.where(user_id: issue.assigned_to_id).first.hours_per_day if
    @days_passed = (Date.today - issue.start_date).to_i - 1

    return @time_left unless @member_hours

    subtract_first_day_hours(issue) if issue.start_date < Date.today
    subtract_hours(issue) if @days_passed > 0

    return 0.0 if @time_left <= 0
    return @time_left

  end

  def subtract_hours(issue)
    @time_left -= @member_hours * @days_passed
  end

  def first_day(issue)
    if issue.start_date && issue.start_time
      @first_day_hours = 17 - (issue.start_time.hour + issue.start_time.min.to_f / 60)
    end
  end

  def subtract_first_day_hours(issue)
    if issue.start_time && first_day(issue) < @member_hours
      @time_left -= @first_day_hours
    else
      @time_left -= @member_hours
    end
  end

end
