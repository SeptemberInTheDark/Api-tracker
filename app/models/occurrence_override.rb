class OccurrenceOverride < ApplicationRecord
  belongs_to :task

  validates :occurrence_date, presence: true, uniqueness: { scope: :task_id }
  validates :status, inclusion: { in: Task::STATUSES }, allow_nil: true
end
