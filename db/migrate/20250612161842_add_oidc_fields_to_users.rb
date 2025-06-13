class AddOidcFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    # OIDC/Okta specific fields
    add_column :users, :okta_sub, :string
    add_index :users, :okta_sub, unique: true

    # Extended user attributes from Okta
    add_column :users, :employee_id, :string
    add_index :users, :employee_id, unique: true
    add_column :users, :phone_number, :string
    add_column :users, :title, :string
    add_column :users, :department, :string
    add_column :users, :office_location, :string
    add_column :users, :manager_email, :string
    add_column :users, :hire_date, :date
    add_column :users, :employee_type, :string
    add_column :users, :active, :boolean, default: true

    # Additional indexes for lookups
    add_index :users, :manager_email
    add_index :users, :department
    add_index :users, :active
  end
end
