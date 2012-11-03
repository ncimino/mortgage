class CreateLoans < ActiveRecord::Migration
  def change
    create_table :loans do |t|
      t.integer :user_id
      t.decimal :asset_price, :precision => 10, :scale => 2
      t.decimal :down_payment, :precision => 10, :scale => 2
      t.integer :payments_per_year
      t.decimal :interest_rate, :precision => 10, :scale => 3
      t.integer :years
      t.decimal :escrow_payment, :precision => 10, :scale => 2
      t.decimal :planned_payment, :precision => 10, :scale => 2
      t.date :first_payment

      t.timestamps
    end
  end
end
