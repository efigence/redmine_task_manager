Redmine::Plugin.register :redmine_task_manager do
  name 'Redmine Task Manager plugin'
  author 'Maria Syczewska'
  description 'This is a plugin for Redmine for managing tasks'
  version '0.0.1'
  url 'https://github.com/efigence/redmine_task_manager'
  author_url 'https://github.com/efigence'
end


ActionDispatch::Callbacks.to_prepare do
  require 'redmine_task_manager/patches/issue_patch'
  require 'redmine_task_manager/patches/member_patch'
end
