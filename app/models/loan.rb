include ActionView::Helpers::TextHelper

class Loan < ActiveRecord::Base

  validates_presence_of :asset_price, :down_payment, :escrow_payment, :first_payment, :interest_rate, :payments_per_year, :planned_payment, :years, :name
  validates_numericality_of :asset_price, :down_payment, :escrow_payment, :interest_rate, :payments_per_year, :planned_payment, :years

  attr_accessible :asset_price, :down_payment, :escrow_payment, :first_payment, :interest_rate, :payments_per_year, :planned_payment, :years, :name

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

  def last_payment
    if rate and loan_amount and real_payment
      last_payment = loan_amount * ( 1 + rate ) ** actual_payments - ( real_payment / rate ) * ( ( 1 + rate ) ** actual_payments - 1 )
      last_payment + real_payment
    end
  end

  def real_payment
    planned_payment - escrow_payment if planned_payment and escrow_payment
  end

  def actual_payments
    if rate and loan_amount and real_payment
      begin
        number_of_payments = (-1 * Math.log( 1 - rate * loan_amount / real_payment) / Math.log( 1 + rate) ).ceil
        (number_of_payments > 0) ? number_of_payments : 0
      rescue
        0
      end
    end
  end

  def payoff_time
    if actual_payments and payments_per_year
      years = actual_payments / payments_per_year
      months = actual_payments % payments_per_year * 12 / payments_per_year
      "#{ pluralize(years, "year") } and #{ pluralize(months, "month") }"
    end
  end

  def payoff_date
    first_payment + (actual_payments * 12 / payments_per_year).months if first_payment and actual_payments
  end

  def actual_payment
    loan_payment + escrow_payment if loan_payment and escrow_payment
  end

  def total_interest
    if planned_payment and actual_payments and last_payment and loan_amount
      interest = planned_payment * ( actual_payments - 1 ) + last_payment - loan_amount
      (interest > 0) ? interest : 0
    end
  end

end
