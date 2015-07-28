module RedmineTaskManager
  module Patches
    module IssuesControllerPatch
      def self.included(base)
        base.class_eval do
          include TaskManagerHelper
          unloadable

          after_filter :create_issue_log, only: [:create]
          after_filter :update_issue_log, only: [:update]


          private

          def issue_log
            @issue_log = IssueLog.new
            @issue_log.issue_id = @issue.id
            @issue_log.project_id = @issue.project_id
            @issue_log.user_id = @issue.assigned_to_id
            @issue_log.date = @issue.start_date
          end

          def create_issue_log
            if @issue.save
              member = Member.where("user_id = ? AND project_id = ?", @issue.assigned_to_id, @issue.project_id).first if @issue.assigned_to_id
              hours_per_day = member.hours_per_day * 60 if member
              hours_per_day ||= 480

              if first_day(@issue)
                first_day_hours = first_day(@issue) * 60 if first_day(@issue) * 60 < hours_per_day
              else
                first_day_hours = hours_per_day
              end

              if @issue.start_date && @issue.estimated_hours
                estimated_due_date = estimated_due_date(@issue)
                days = @issue.start_date.business_days_until(estimated_due_date) - 1

                issue_log
                @issue_log.time = first_day_hours
                @issue_log.save
                @issue.start_date += 1

                days.times do |d|
                  issue_log
                  @issue_log.time = hours_per_day
                  @issue_log.save
                  @issue.start_date += 1
                end

                hours_per_day = @issue.estimated_hours * 60 - first_day_hours - days * hours_per_day
                issue_log
                @issue_log.time = hours_per_day
                @issue_log.save

              else
                issue_log
                @issue_log.time = hours_per_day
                @issue_log.save
              end

            end
          end

          def update_issue_log
          end

        end
      end
    end
  end
end

unless IssuesController.included_modules.include?(RedmineTaskManager::Patches::IssuesControllerPatch)
  IssuesController.send(:include, RedmineTaskManager::Patches::IssuesControllerPatch)
end
