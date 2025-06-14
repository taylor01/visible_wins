class CreateScheduleStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :schedule_statuses do |t|
      t.string :name, null: false
      t.string :display_name, null: false
      t.string :color_class, null: false
      t.boolean :active, default: true, null: false
      t.integer :sort_order, null: false

      t.timestamps
    end

    add_index :schedule_statuses, :name, unique: true
    add_index :schedule_statuses, :sort_order
  end
end
