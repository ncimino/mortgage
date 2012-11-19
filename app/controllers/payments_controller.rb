class PaymentsController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :create, :actual, :session_create]

  def actual
    @loan = Loan.new(params[:loan])
    @loan.id = params[:loan][:id]
    @payments = @loan.payments
    render :partial => "actual"
  end

  def new
    @loan = Loan.find(params[:loan_id])
    if @loan.payments.last
      @payment = @loan.payments.last.dup
      @payment.date = @payment.date + (12 / @loan.payments_per_year).months
    else
      @payment = @loan.payments.new
      @payment.date = @loan.first_payment
      @payment.amount = @loan.planned_payment
      @payment.escrow = @loan.escrow_payment
    end
    render :partial => "new"
  end

  def edit
    @payment = Payment.find(params[:id])
    @loan = @payment.loan
    render :partial => "edit"
  end

  def create
    @loan = Loan.find(params[:loan_id])
    @payment = @loan.payments.build(params[:payment])
    if @payment.save
      @payment = @loan.payments.last.dup
      @payment.date = @payment.date + (12 / @loan.payments_per_year).months
    end
    render :partial => "new"
  end

  def update
    @payment = Payment.find(params[:id])
    @loan = @payment.loan
    if @payment.update_attributes(params[:payment])
      @payment = @loan.payments.last.dup
      @payment.date = @payment.date + (12 / @loan.payments_per_year).months
      render :partial => "new", notice: 'Payment was successfully updated.'
    else
      render :partial => "edit"
    end
  end

  def destroy
    @payment = Payment.find(params[:id])
    @loan = @payment.loan
    @payments = @loan.payments
    @payment.destroy
    render :partial => "loans/payments"
  end
end
