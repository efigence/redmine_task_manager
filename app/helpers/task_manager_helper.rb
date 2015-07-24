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
    false
  end

  def has_underbooked_members?(project)
    false
  end

  # super time
  def super_time(issue)

    return unless issue.estimated_hours && issue.start_date

    subtract_first_day_hours(issue)
    subtract_hours(issue)

    return issue.start_date + @days

  end

  def first_day(issue)
    if issue.start_date && issue.start_time
      @first_day_hours = 17 - (issue.start_time.hour + issue.start_time.min.to_f / 60)
    end
    return @first_day_hours
  end

  def subtract_first_day_hours(issue)
    @estimated_time_left = issue.estimated_hours
    @member_hours = assignees_hours_per_day(issue)
    @days = 0

    issue.start_time && first_day(issue) < @member_hours ? (@estimated_time_left -= @first_day_hours) : (@estimated_time_left -= @member_hours)
    @days += 1
  end

  def subtract_hours(issue)
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
      time_left(i) > assignees_hours_per_day(i) ? time += assignees_hours_per_day(i) : time += time_left(i)
    end

    if time > @memb_hours
      return 'OVERBOOKED!'
    elsif time < @memb_hours
      return 'UNDERBOOKED!'
    else
      return 'OK!'
    end

  end

end
