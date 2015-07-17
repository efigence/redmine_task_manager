class ShowStartDateHookListener < Redmine::Hook::ViewListener
  render_on :view_issues_show_details_bottom, :partial => "issues/show_start_date"
end
