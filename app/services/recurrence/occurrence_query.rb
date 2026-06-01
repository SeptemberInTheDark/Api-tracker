module Recurrence
  class OccurrenceQuery
    def initialize(scope, from:, to:, statuses: nil)
      @scope = scope
      @from = from
      @to = to
      @statuses = Array(statuses).compact_blank
    end

    def call
      @scope.flat_map { |task| occurrences_for(task) }
            .reject(&:cancelled)
            .select { |occurrence| include_status?(occurrence.status) }
            .sort_by { |occurrence| [occurrence.occurrence_date, occurrence.task.id] }
    end

    private

    def occurrences_for(task)
      overrides_by_date = task.occurrence_overrides.index_by(&:occurrence_date)

      if task.recurrence_rule.present?
        task.recurrence_rule.occurrence_dates(@from, @to).map do |date|
          TaskOccurrence.from_task(task, date, overrides_by_date[date])
        end
      elsif task.due_date.between?(@from, @to)
        [TaskOccurrence.from_task(task, task.due_date, overrides_by_date[task.due_date])]
      else
        []
      end
    end

    def include_status?(status)
      @statuses.blank? || @statuses.include?(status)
    end
  end
end
