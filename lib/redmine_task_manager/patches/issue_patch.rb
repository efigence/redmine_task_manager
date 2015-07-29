module RedmineTaskManager
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          unloadable

          has_many :issue_logs, dependent: :destroy
          after_create :create_issue_log

          safe_attributes 'start_time'

          scope :dated, ->(date) { where("(start_date IS NULL)
            OR (start_date IS NOT NULL AND start_date <= ?)", date) }

          def create_issue_log
            create_log
            create_empty_log_if_needed
          end

          private

          def create_log
            time_left = estimated_hours.to_i * 60
            day = start_date || created_on

            while time_left > 0
              if should_skip_day?(day)
                day += 1
                next
              end

              minutes = minutes_per_day(day, time_left)
              build_issue_log(day, minutes)
              time_left -= minutes
              day += 1
            end
          end

          def should_skip_day?(day)
            day.holiday? || day.saturday? || day.sunday?
          end

          def create_empty_log_if_needed
            build_issue_log(start_date || created_on) unless issue_logs.exists?
          end

          def first_day?(day)
            (start_date || created_on) == day
          end

          def member
            Member.where("user_id = ? AND project_id = ?", assigned_to_id, project_id).first if assigned_to_id
          end

          def minutes_per_ordinal_day
            @minutes_per_day ||= (member.try(:hours_per_day) || 8) * 60
          end

          def minutes_per_day(day, time_left)
            minutes = first_day?(day) ? minutes_per_first_day : minutes_per_ordinal_day
            minutes = time_left if time_left < minutes
            minutes
          end

          def minutes_per_first_day
            @minutes ||= time_for_first_day || minutes_per_ordinal_day
          end

          def time_for_first_day
            return nil unless start_time
            minutes = (17 - (start_time.hour + start_time.min.to_f / 60)) * 60
            minutes = minutes_per_ordinal_day if minutes > minutes_per_ordinal_day
            minutes
          end

          def build_issue_log(date, time=0)
            IssueLog.create(
              issue_id: id,
              user_id: assigned_to_id,
              project_id: project_id,
              date: date,
              time: time)
          end
        end
      end
    end
  end
end

unless Issue.included_modules.include?(RedmineTaskManager::Patches::IssuePatch)
  Issue.send(:include, RedmineTaskManager::Patches::IssuePatch)
end
