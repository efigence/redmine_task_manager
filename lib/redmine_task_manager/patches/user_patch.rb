module RedmineTaskManager
  module Patches
    module UserPatch
      def self.included(base)
        base.class_eval do
          unloadable

          def has_task_manager_access?
            !(user_group_ids & groups_with_task_manager_access).blank?
          end

          def user_group_ids
            User.current.groups.select('id').collect{|el| el.id.to_s}
          end

          def groups_with_task_manager_access
            Setting.plugin_redmine_task_manager["groups"] || []
          end

        end
      end
    end
  end
end

unless User.included_modules.include?(RedmineTaskManager::Patches::UserPatch)
  User.send(:include, RedmineTaskManager::Patches::UserPatch)
end
