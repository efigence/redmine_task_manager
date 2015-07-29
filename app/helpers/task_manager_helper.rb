module TaskManagerHelper


  # methods for users
  def members_hours_per_day(user, project)
    member = Member.where("project_id = ? AND user_id = ?", project.id, user.id).first
    member.hours_per_day if member != nil && member.hours_per_day
  end

  def members_issue_count(user, project)
    Issue.open.where("project_id = ? AND assigned_to_id = ?", project.id, user.id).count
  end

  def members_estimated_time(user, project)
    estimated_time = 0
    Issue.open.where("project_id = ? AND assigned_to_id = ?", project.id, user.id).each do |i|
      estimated_time += i.estimated_hours if i.estimated_hours
    end
    return estimated_time if estimated_time > 0
  end

  # methods for tasks
  def issue_assigned_to_name(issue)
    if issue.assigned_to
      issue.assigned_to.name
    else
      ' This task is not assigned.'
    end
  end

  def assignees_hours_per_day(issue)
    member = Member.where("project_id = ? AND user_id = ?", issue.project.id, issue.assigned_to_id)
    !member.empty? && member.first.hours_per_day ? member.first.hours_per_day : 8.0
  end

  def issue_time_entries(issue)
    time_entries = 0
    unless TimeEntry.where("issue_id = ? and spent_on = ?", issue.id, Date.today).empty?
      TimeEntry.where("issue_id = ? and spent_on = ?", issue.id, Date.today).each do |t|
        time_entries += t.hours if t.hours
      end
    end
    return time_entries if time_entries > 0
  end

  # others
  def has_unassigned_issues?(project)
    project.issues.map(&:assigned_to_id).include? nil
  end

  def has_overbooked_members?(project)
    overload = 0
    project.users.each do |u|
      overload += 1 if overload(u, project) == 'OVERBOOKED!'
    end
    return true if overload > 0
  end

  def has_underbooked_members?(project)
    underload = 0
    project.users.each do |u|
      underload += 1 if overload(u, project) == 'UNDERBOOKED!'
    end
    return true if underload > 0
  end

  # estimated due date
  def estimated_due_date(issue)

    return unless issue.estimated_hours && issue.start_date

    subtract_first_day_hours(issue)
    subtract_hours(issue)

    return @days.business_days.after(issue.start_date)

  end

  def first_day(issue)
    if issue.start_date && issue.start_time
      first_day_hours = 17 - (issue.start_time.hour + issue.start_time.min.to_f / 60)
    end
    return first_day_hours
  end

  def subtract_first_day_hours(issue)
    @estimated_time_left = issue.estimated_hours
    @member_hours = assignees_hours_per_day(issue)

    if issue.start_time && first_day(issue) < @member_hours
      @estimated_time_left -= @first_day_hours
    else
      @estimated_time_left -= @member_hours
    end

  end

  def subtract_hours(issue)
    @days = 0
    until @estimated_time_left < 0
      @estimated_time_left -= @member_hours
      @days += 1
    end
  end

  # time_left
  def time_left(issue)

    return 0 unless issue.estimated_hours && issue.start_date

    @time_left = issue.estimated_hours
    @memb_hours = assignees_hours_per_day(issue)
    @days_passed = (Date.today - issue.start_date).to_i - 1

    subtract_first_day_hours(issue) if issue.start_date < Date.today
    subtract_hours_left(issue) if @days_passed > 0

    return @time_left

  end

  def subtract_hours_left(issue)
    @time_left -= @memb_hours * @days_passed
  end

  def overload(user, project)
    issues = Issue.open.where("assigned_to_id = ? AND project_id = ?", user.id, project.id)
    member = Member.where("user_id = ? AND project_id = ?", user.id, project.id).first
    time = 0

    issues.each do |i|
      hours_per_day = assignees_hours_per_day(i)
      time_left(i) > hours_per_day ? time += hours_per_day : time += time_left(i)
    end

    return 'OVERBOOKED!' if time > @memb_hours
    return 'UNDERBOOKED!' if time < @memb_hours
    return 'OK'
  end

end
