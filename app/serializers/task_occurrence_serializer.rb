class TaskOccurrenceSerializer
  def initialize(occurrence)
    @occurrence = occurrence
  end

  def as_json(*)
    {
      id: @occurrence.id,
      task_id: @occurrence.task.id,
      title: @occurrence.title,
      description: @occurrence.description,
      occurrence_date: @occurrence.occurrence_date.iso8601,
      due_time: @occurrence.due_time&.strftime("%H:%M"),
      status: @occurrence.status,
      recurring: @occurrence.recurring?,
      detached: @occurrence.override.present?,
      tags: @occurrence.task.tags.order(:name).map { |tag| TagSerializer.new(tag).as_json }
    }
  end
end
