class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :role
      t.references :team, null: false, foreign_key: true
      t.string :password_digest
      t.boolean :admin

      t.timestamps
    end
  end
end
