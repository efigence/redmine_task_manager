class StartTimeHookListener < Redmine::Hook::ViewListener
  render_on :view_issues_show_details_bottom, :partial => "issues/start_time"
end
