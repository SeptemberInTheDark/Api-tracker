class Tag < ApplicationRecord
  has_many :task_tags, dependent: :destroy
  has_many :tasks, through: :task_tags

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 60 }

  before_update :prevent_locked_update
  before_destroy :prevent_locked_destroy

  REQUIRED_NAMES = ["отчетность", "операции", "звонок"].freeze

  private

  def prevent_locked_update
    return unless locked?

    errors.add(:base, "locked tags cannot be changed")
    throw :abort
  end

  def prevent_locked_destroy
    return unless locked?

    errors.add(:base, "locked tags cannot be deleted")
    throw :abort
  end
end
