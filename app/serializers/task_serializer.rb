class TaskSerializer
  def initialize(task)
    @task = task
  end

  def as_json(*)
    {
      id: @task.id,
      title: @task.title,
      description: @task.description,
      due_date: @task.due_date&.iso8601,
      status: @task.status,
      tags: @task.tags.order(:name).map { |tag| TagSerializer.new(tag).as_json },
      recurrence_rule: recurrence_rule
    }
  end

  private

  def recurrence_rule
    rule = @task.recurrence_rule
    return unless rule

    {
      id: rule.id,
      recurrence_type: rule.recurrence_type,
      interval: rule.interval,
      day_of_month: rule.day_of_month,
      starts_on: rule.starts_on&.iso8601,
      ends_on: rule.ends_on&.iso8601,
      specific_dates: rule.specific_dates.map(&:iso8601),
      parity: rule.parity
    }.compact
  end
end
