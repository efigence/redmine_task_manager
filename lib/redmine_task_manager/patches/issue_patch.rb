module RedmineTaskManager
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          unloadable

          has_many :issue_logs, dependent: :destroy

          safe_attributes 'start_time'

          scope :dated, ->(date) { where("(start_date IS NULL)
            OR (start_date IS NOT NULL AND start_date <= ?)", date) }

        end
      end
    end
  end
end

unless Issue.included_modules.include?(RedmineTaskManager::Patches::IssuePatch)
  Issue.send(:include, RedmineTaskManager::Patches::IssuePatch)
end
