module TaskManagerHelper

  def estimated_hours_per_day(issue)
    if issue.due_date && issue.due_date > issue.start_date && issue.estimated_hours
      issue.estimated_hours / (issue.due_date - issue.start_date)
    else
      issue.estimated_hours
    end
  end

  def assignees_hours_per_day(issue)
    member = Member.where(user_id: issue.assigned_to_id).first
    if member != nil && member.hours_per_day
      member.hours_per_day
    else
      'undefined'
    end
  end

  def issue_assigned_to(issue)
    if issue.assigned_to
      issue.assigned_to
    else
      'This task is not assigned.'
    end
  end

end
