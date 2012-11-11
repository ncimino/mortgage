class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :loan_id, :null => false
      t.decimal :amount, :precision => 10, :scale => 2, :default => 0
      t.decimal :escrow, :precision => 10, :scale => 2, :default => 0
      t.decimal :interest, :precision => 10, :scale => 2, :default => 0
      t.date :date, :null => false

      t.timestamps
    end
    add_index :payments, [:loan_id, :date]
  end
end
