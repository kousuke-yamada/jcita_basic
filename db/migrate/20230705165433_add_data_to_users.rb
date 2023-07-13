class AddDataToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :records1, :float, default: 999.99
    add_column :users, :records2, :float, default: 999.99
    add_column :users, :records3, :float, default: 999.99
    add_column :users, :records4, :float, default: 999.99
    add_column :users, :records5, :float, default: 999.99
  end
end
