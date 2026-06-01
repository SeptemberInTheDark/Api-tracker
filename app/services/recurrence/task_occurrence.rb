module Recurrence
  TaskOccurrence = Data.define(
    :task,
    :occurrence_date,
    :status,
    :title,
    :description,
    :due_time,
    :cancelled,
    :override
  ) do
    def self.from_task(task, occurrence_date, override = nil)
      new(
        task: task,
        occurrence_date: occurrence_date,
        status: override&.status || task.status,
        title: override&.title.presence || task.title,
        description: override&.description.presence || task.description,
        due_time: override&.due_time,
        cancelled: override&.cancelled || false,
        override: override
      )
    end

    def id
      "#{task.id}:#{occurrence_date.iso8601}"
    end

    def recurring?
      task.recurrence_rule.present?
    end
  end
end
