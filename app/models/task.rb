class Task < ApplicationRecord
  STATUSES = %w[pending in_progress done cancelled].freeze

  has_one :recurrence_rule, dependent: :destroy
  has_many :task_tags, dependent: :destroy
  has_many :tags, through: :task_tags
  has_many :occurrence_overrides, dependent: :destroy

  accepts_nested_attributes_for :recurrence_rule, allow_destroy: true

  enum :status, STATUSES.index_by(&:itself), default: "pending", validate: true

  validates :title, presence: true, length: { maximum: 120 }
  validates :description, presence: true
  validates :due_date, presence: true

  before_validation :sync_recurrence_start

  private

  def sync_recurrence_start
    return if recurrence_rule.blank? || recurrence_rule.starts_on.present?

    recurrence_rule.starts_on = due_date
  end
end
