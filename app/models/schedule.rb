class Schedule # < ActiveModel::Array
  #include ActiveRecord::Loan

  #belongs_to :loan

  attr_accessor :loan

  def initialize(loan)
    @loan = loan
  end

  def persisted?
    false
  end

  def available?
    @loan.loan_amount and @loan.actual_payments and @loan.planned_payment and @loan.rate and @loan.escrow_payment and @loan.payments_per_year and @loan.first_payment
  end

  def ideal
    if available?
      number = 0
      schedule = [{:number => "", :date => "", :total => @loan.loan_amount, :to_principle => 0, :interest => 0, :payment => 0, :escrow => 0}]
      date = @loan.first_payment - 1.month
      total = @loan.loan_amount

      (1..@loan.actual_payments).each do |i|
        number += 1
        #interest = number_with_precision(total * @loan.rate, :precision => 2)
        interest = total * @loan.rate
        escrow = @loan.escrow_payment
        total_w_additions = total + interest + escrow
        payment = (@loan.planned_payment > total_w_additions) ? total_w_additions : @loan.planned_payment
        date += (12 / @loan.payments_per_year).months
        to_principle = payment - interest - escrow
        total -= to_principle
        schedule += [
            {:number => number, :date => date, :total => total, :to_principle => to_principle, :interest => interest, :payment => payment, :escrow => escrow}
        ];
      end
      schedule
    end
  end

  def sum_interest_before records, before_date
    selected = records.select { |record| record.date.to_time.to_i < before_date.to_time.to_i }
    selected.sum(&:interest)
  end

  def sum_amount_before records, before_date
    selected = records.select { |record| record.date.to_time.to_i < before_date.to_time.to_i }
    selected.sum(&:amount)
  end

  def sum_escrow_before records, before_date
    selected = records.select { |record| record.date.to_time.to_i < before_date.to_time.to_i }
    selected.sum(&:escrow)
  end

  def sum_interest_between records, after_date, before_date
    selected = records.select { |record| record.date.to_time.to_i < before_date.to_time.to_i && record.date.to_time.to_i >= after_date.to_time.to_i }
    selected.sum(&:interest)
  end

  def sum_amount_between records, after_date, before_date
    selected = records.select { |record| record.date.to_time.to_i < before_date.to_time.to_i && record.date.to_time.to_i >= after_date.to_time.to_i }
    selected.sum(&:amount)
  end

  def sum_escrow_between records, after_date, before_date
    selected = records.select { |record| record.date.to_time.to_i < before_date.to_time.to_i && record.date.to_time.to_i >= after_date.to_time.to_i}
    selected.sum(&:escrow)
  end

  def between records, after_date, before_date
    records.select { |record|
      record.date.to_time.to_i < before_date.to_time.to_i && record.date.to_time.to_i >= after_date.to_time.to_i
    }
  end

  def actual
    if available?

      number = 0
      schedule = [{:number => '', :date => '', :total => @loan.loan_amount,
                   :to_principle => 0, :interest => 0, :payment => 0, :escrow => 0}]
      date = @loan.first_payment
      interest = sum_interest_before @loan.payments, date
      escrow = sum_escrow_before @loan.payments, date
      payment = sum_amount_before @loan.payments, date
      to_principle = payment - interest - escrow
      total = @loan.loan_amount - payment
      schedule += [{:class => "manually-entered", :number => number, :date => "-", :total => total,
                    :to_principle => to_principle, :interest => interest, :payment => payment, :escrow => escrow}] if payment > 0

      while 100.0*total.to_int > 0
        number += 1
        payment = between @loan.payments, date, date + (12 / @loan.payments_per_year).months

        if payment.length == 0
          css_class = ""
          interest = total * @loan.rate
          escrow = @loan.escrow_payment
          total_w_additions = total + interest + escrow
          payment = (@loan.planned_payment > total_w_additions) ? total_w_additions : @loan.planned_payment
        else
          css_class = "manually-entered"
          interest = sum_interest_between payment, date, date + (12 / @loan.payments_per_year).months
          escrow = sum_escrow_between payment, date, date + (12 / @loan.payments_per_year).months
          payment = sum_amount_between payment, date, date + (12 / @loan.payments_per_year).months
        end
        to_principle = payment - interest - escrow
        total -= to_principle

        schedule += [
            {:class => css_class, :number => number, :date => date, :total => total,
             :to_principle => to_principle, :interest => interest, :payment => payment, :escrow => escrow}
        ];
        date += (12 / @loan.payments_per_year).months
      end

      schedule
    end
  end

end
