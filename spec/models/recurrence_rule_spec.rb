require "rails_helper"

RSpec.describe RecurrenceRule, type: :model do
  let(:task) { Task.create!(title: "Обход", description: "Проверить пациентов", due_date: "2026-06-01") }

  it "expands daily rules by interval without materializing future rows" do
    rule = task.create_recurrence_rule!(recurrence_type: "daily", interval: 2, starts_on: "2026-06-01")

    expect(rule.occurrence_dates(Date.new(2026, 6, 1), Date.new(2026, 6, 7))).to eq(
      [Date.new(2026, 6, 1), Date.new(2026, 6, 3), Date.new(2026, 6, 5), Date.new(2026, 6, 7)]
    )
  end

  it "skips impossible monthly dates" do
    rule = task.create_recurrence_rule!(recurrence_type: "monthly_day", day_of_month: 31, starts_on: "2026-04-01")

    expect(rule.occurrence_dates(Date.new(2026, 4, 1), Date.new(2026, 6, 30))).to eq(
      [Date.new(2026, 5, 31)]
    )
  end

  it "returns only configured specific dates inside the window" do
    rule = task.create_recurrence_rule!(
      recurrence_type: "specific_dates",
      starts_on: "2026-06-01",
      specific_dates: [Date.new(2026, 6, 2), Date.new(2026, 6, 9)]
    )

    expect(rule.occurrence_dates(Date.new(2026, 6, 1), Date.new(2026, 6, 3))).to eq([Date.new(2026, 6, 2)])
  end

  it "supports even and odd day parity" do
    even = task.create_recurrence_rule!(recurrence_type: "day_parity", parity: "even", starts_on: "2026-06-01")

    expect(even.occurrence_dates(Date.new(2026, 6, 1), Date.new(2026, 6, 5))).to eq(
      [Date.new(2026, 6, 2), Date.new(2026, 6, 4)]
    )
  end
end
