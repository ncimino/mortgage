class AddNameToLoans < ActiveRecord::Migration
  def change
    add_column :loans, :name, :string
  end
end
