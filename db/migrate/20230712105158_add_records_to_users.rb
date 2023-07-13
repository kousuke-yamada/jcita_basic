class AddRecordsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :records6, :float, default: 999.99
    add_column :users, :records7, :float, default: 999.99
    add_column :users, :records8, :float, default: 999.99
    add_column :users, :records9, :float, default: 999.99
  end
end
