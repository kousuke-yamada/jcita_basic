class AddDataToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :records1, :integer
    add_column :users, :records2, :integer
    add_column :users, :records3, :integer
    add_column :users, :records4, :integer
    add_column :users, :records5, :integer
  end
end
