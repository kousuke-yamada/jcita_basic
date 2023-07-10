class AddColumnToLineusers < ActiveRecord::Migration[5.1]
  def change
    add_column :lineusers, :provider, :string
    add_column :lineusers, :uid, :string
    add_column :lineusers, :name, :string
  end
end
