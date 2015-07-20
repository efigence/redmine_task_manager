module RedmineTaskManager
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          unloadable

          safe_attributes 'start_time'

        end
      end
    end
  end
end

unless Issue.included_modules.include?(RedmineTaskManager::Patches::IssuePatch)
  Issue.send(:include, RedmineTaskManager::Patches::IssuePatch)
end
