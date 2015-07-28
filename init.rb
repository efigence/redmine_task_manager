Redmine::Plugin.register :redmine_task_manager do
  name 'Redmine Task Manager plugin'
  author 'Maria Syczewska'
  description 'This is a plugin for Redmine for managing tasks'
  version '0.0.1'
  url 'https://github.com/efigence/redmine_task_manager'
  author_url 'https://github.com/efigence'

  menu :top_menu,
  :task_manager,
  { :controller => 'task_manager', :action => 'index' },
  caption: :label_task_manager,
  :if => proc { User.current.logged? && (User.current.admin? || User.current.has_task_manager_access?) }

  settings :default => {
    'groups' => []
    }, :partial => 'settings/redmine_task_manager_settings'


    ActionDispatch::Callbacks.to_prepare do
      require 'redmine_task_manager/patches/issue_patch'
      require 'redmine_task_manager/patches/issues_controller_patch'
      require 'redmine_task_manager/patches/member_patch'
      require 'redmine_task_manager/patches/members_controller_patch'
      require 'redmine_task_manager/patches/user_patch'
      require 'redmine_task_manager/hooks/start_time'
    end

end
