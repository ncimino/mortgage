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
      schedule = [{:number => number, :date => "-", :total => @loan.loan_amount, :to_principle => 0, :interest => 0, :payment => 0, :escrow => 0}]
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

  def actual
    if available?

      number = 0
      schedule = [{:number => '', :date => '', :total => @loan.loan_amount,
                   :to_principle => 0, :interest => 0, :payment => 0, :escrow => 0}]
      interest = @loan.payments.before(@loan.first_payment).sum("interest")
      escrow = @loan.payments.before(@loan.first_payment).sum("escrow")
      payment = @loan.payments.before(@loan.first_payment).sum("amount")
      to_principle = payment - interest - escrow
      total = @loan.loan_amount - payment
      schedule += [{:class => "manually-entered", :number => number, :date => "-", :total => total,
                    :to_principle => to_principle, :interest => interest, :payment => payment, :escrow => escrow}] if payment > 0
      date = @loan.first_payment

      while 100.0*total.to_int > 0
        number += 1
        payment = @loan.payments.between(date, date + (12 / @loan.payments_per_year).months)

        if payment.length == 0
          css_class = ""
          interest = total * @loan.rate
          escrow = @loan.escrow_payment
          total_w_additions = total + interest + escrow
          payment = (@loan.planned_payment > total_w_additions) ? total_w_additions : @loan.planned_payment
        else
          css_class = "manually-entered"
          interest = payment.sum("interest")
          escrow = payment.sum("escrow")
          payment = payment.sum("amount")
        end
        to_principle = payment - interest - escrow
        total -= to_principle

        schedule += [
            {:class => css_class, :number => number, :date => date, :total => total, :to_principle => to_principle, :interest => interest, :payment => payment, :escrow => escrow}
        ];
        date += (12 / @loan.payments_per_year).months
      end

      schedule
    end
  end

end
