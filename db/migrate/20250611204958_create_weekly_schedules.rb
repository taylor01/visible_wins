class CreateWeeklySchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :weekly_schedules do |t|
      t.references :user, null: false, foreign_key: true
      t.date :week_start_date
      t.string :sunday
      t.string :monday
      t.string :tuesday
      t.string :wednesday
      t.string :thursday
      t.string :friday
      t.string :saturday

      t.timestamps
    end
  end
end
