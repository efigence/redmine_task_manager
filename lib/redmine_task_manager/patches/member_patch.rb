module RedmineTaskManager
  module Patches
    module MemberPatch
      def self.included(base)
        base.class_eval do
          unloadable

          include Redmine::SafeAttributes

          safe_attributes 'hours_per_day'

        end
      end
    end
  end
end

unless Member.included_modules.include?(RedmineTaskManager::Patches::MemberPatch)
  Member.send(:include, RedmineTaskManager::Patches::MemberPatch)
end
