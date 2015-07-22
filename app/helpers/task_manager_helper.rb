module TaskManagerHelper

  def estimated_hours_per_day(issue)
    if issue.due_date && issue.due_date > issue.start_date && issue.estimated_hours
      estimated_hours_per_day = ((issue.estimated_hours / (issue.due_date - issue.start_date)) * 2).round / 2.0
    else
      estimated_hours_per_day = issue.estimated_hours
    end
    return estimated_hours_per_day
  end

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

  def time_difference(issue)
    Member.where(user_id: issue.assigned_to_id)
      .first.hours_per_day - estimated_hours_per_day(issue) if Member.where(user_id: issue.assigned_to_id).first
  end

  def has_overbooked_members?
    @issues.each do |i|
      if time_difference(i) && time_difference(i) < 0
        return false
      else
        return true
      end
    end
  end

  def has_underbooked_members?
    @issues.each do |i|
      if time_difference(i) && time_difference(i) > 0
        return false
      else
        return true
      end
    end
  end

end
