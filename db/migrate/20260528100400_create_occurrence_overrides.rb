class CreateOccurrenceOverrides < ActiveRecord::Migration[8.0]
  def change
    create_table :occurrence_overrides do |t|
      t.references :task, null: false, foreign_key: true
      t.date :occurrence_date, null: false
      t.string :status
      t.string :title
      t.text :description
      t.time :due_time
      t.boolean :cancelled, null: false, default: false

      t.timestamps
    end

    add_index :occurrence_overrides, %i[task_id occurrence_date], unique: true
    add_index :occurrence_overrides, :status
  end
end
