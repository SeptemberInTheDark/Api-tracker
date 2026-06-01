class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.date :due_date, null: false
      t.string :status, null: false, default: "pending"

      t.timestamps
    end

    add_index :tasks, :due_date
    add_index :tasks, :status
  end
end
