class CreateRecurrenceRules < ActiveRecord::Migration[8.0]
  def change
    create_table :recurrence_rules do |t|
      t.references :task, null: false, foreign_key: true, index: { unique: true }
      t.string :recurrence_type, null: false
      t.integer :interval
      t.integer :day_of_month
      t.date :starts_on, null: false
      t.date :ends_on
      t.date :specific_dates, array: true, null: false, default: []
      t.string :parity

      t.timestamps
    end

    add_index :recurrence_rules, :recurrence_type
    add_index :recurrence_rules, :starts_on
    add_index :recurrence_rules, :ends_on
  end
end
