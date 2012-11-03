class Loan < ActiveRecord::Base

  validates_presence_of :asset_price, :down_payment, :escrow_payment, :first_payment, :interest_rate, :payments_per_year, :planned_payment, :years, :name
  validates_numericality_of :asset_price, :down_payment, :escrow_payment, :interest_rate, :payments_per_year, :planned_payment, :years

  attr_accessible :asset_price, :down_payment, :escrow_payment, :first_payment, :interest_rate, :payments_per_year, :planned_payment, :years, :name
  #attr_reader :loan_amount, :expected_payments, :loan_payment, :actual_payment, :payoff_date, :payoff_time
  attr_reader :payoff_date, :payoff_time

  belongs_to :user

  def loan_amount
     asset_price - down_payment if asset_price and down_payment
  end

  def expected_payments
    years * payments_per_year if years and payments_per_year
  end

  def rate
    interest_rate / ( 100.0 * payments_per_year) if interest_rate and payments_per_year
  end

  def loan_payment
    if rate and loan_amount and expected_payments
      rate * loan_amount / ( 1 -  ( 1 + rate ) ** ( -1 * expected_payments ) )
    end
  end

  def actual_payment
    loan_payment + escrow_payment if loan_payment and escrow_payment
  end

end
