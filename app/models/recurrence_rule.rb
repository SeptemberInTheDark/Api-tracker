class RecurrenceRule < ApplicationRecord
  TYPES = %w[daily monthly_day specific_dates day_parity].freeze
  PARITIES = %w[even odd].freeze

  belongs_to :task

  enum :recurrence_type, TYPES.index_by(&:itself), validate: true

  validates :starts_on, presence: true
  validates :interval, numericality: { only_integer: true, greater_than: 0 }, if: :daily?
  validates :day_of_month, numericality: { only_integer: true, in: 1..31 }, if: :monthly_day?
  validates :parity, inclusion: { in: PARITIES }, if: :day_parity?
  validate :ends_on_after_starts_on
  validate :specific_dates_are_present, if: :specific_dates?

  before_validation :normalize_specific_dates

  def occurrence_dates(window_start, window_end)
    effective_start = [starts_on, window_start].max
    effective_end = [ends_on || window_end, window_end].min
    return [] if effective_end < effective_start

    case recurrence_type
    when "daily"
      daily_dates(effective_start, effective_end)
    when "monthly_day"
      monthly_dates(effective_start, effective_end)
    when "specific_dates"
      specific_dates.select { |date| date.between?(effective_start, effective_end) }
    when "day_parity"
      (effective_start..effective_end).select { |date| date.day.public_send("#{parity}?") }
    else
      []
    end
  end

  private

  def daily_dates(effective_start, effective_end)
    step = interval || 1
    offset = (effective_start - starts_on).to_i
    first_offset = offset + ((step - (offset % step)) % step)
    first_date = starts_on + first_offset.days

    dates = []
    cursor = first_date
    while cursor <= effective_end
      dates << cursor
      cursor += step.days
    end
    dates
  end

  def monthly_dates(effective_start, effective_end)
    dates = []
    cursor = effective_start.beginning_of_month
    while cursor <= effective_end
      date = safe_date(cursor.year, cursor.month, day_of_month)
      dates << date if date&.between?(effective_start, effective_end)
      cursor = cursor.next_month
    end
    dates
  end

  def safe_date(year, month, day)
    Date.new(year, month, day)
  rescue Date::Error
    nil
  end

  def normalize_specific_dates
    self.specific_dates = Array(specific_dates).compact.map { |date| date.is_a?(Date) ? date : Date.iso8601(date.to_s) }.uniq.sort
  rescue Date::Error
    errors.add(:specific_dates, "must contain ISO 8601 dates")
  end

  def ends_on_after_starts_on
    return if starts_on.blank? || ends_on.blank? || ends_on >= starts_on

    errors.add(:ends_on, "must be on or after starts_on")
  end

  def specific_dates_are_present
    errors.add(:specific_dates, "must contain at least one date") if specific_dates.blank?
  end
end
