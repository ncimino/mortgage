class SessionPaymentsController < ApplicationController
  before_filter :get_loan, :get_payments

  def get_loan
    @loan = Loan.new(session[:loan])
  end

  def get_payments
    @payments = []
    if session[:payments]
      session[:payments].each { |p|
        this_payment = @loan.payments.new(p)
        this_payment.id = p[:id]
        @payments << this_payment
      }
      @payments.sort! { |a,b| a.date <=> b.date }
    end
  end

  def actual
    render :partial => "actual"
  end


  def new
    if @loan.payments.last
      @payment = @payments.last.dup
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
    @payment = @loan.payments.new(session[:payments].select { |payment| payment[:id] == params[:id].to_i })
    render :partial => "edit"
  end

  def create
    p = params[:payment]
    p[:id] = @payments.last.nil? ? 1 : @payments.last.id + 1
    @payment = @loan.payments.new(p)
    if @payment.valid?
      session[:payments] ||= []
      session[:payments] << p
      get_payments
      @payment = @payments.last.dup
      @payment.date = @payment.date + (12 / @loan.payments_per_year).months
    end
    render :partial => "new"
  end

  def update
    @payment = @loan.payments.new(params[:payment])
    params[:payment][:id] = @payments.last.nil? ? 1 : @payments.last.id + 1
    if @payment.valid?
      session[:payments].delete_if { |payment| payment[:id] == params[:id].to_i }
      session[:payments] << params[:payment]
      @payment = @loan.payments.last.dup
      @payment.date = @payment.date + (12 / @loan.payments_per_year).months
      render :partial => "new", notice: 'Payment was successfully updated.'
    else
      render :partial => "edit"
    end
  end

  def destroy
    Rails.logger.debug session[:payments].to_yaml
    session[:payments].delete_if { |payment| payment[:id] == params[:id].to_i }
    get_payments
    render :partial => "actual"
  end
end
