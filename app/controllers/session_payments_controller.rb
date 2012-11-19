class SessionPaymentsController < ApplicationController

  def actual
    @loan = Loan.new(session[:loan])
    @payments = @loan.payments
    @payments.sort! { |a,b| a.date <=> b.date }
    render :partial => "actual"
  end


  def new
    @loan = Loan.new(session[:loan])
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
    @loan = Loan.new(session[:loan])
    @payment = session[:loan][:payments].select { |payment| payment.id == params[:id].to_i }
    render :partial => "edit"
  end

  def create
    @loan = Loan.new(session[:loan])
    @payment = @loan.payments.new(params[:payment])
    session[:loan][:payments] ||= []
    @payment.id = session[:loan][:payments].last.nil? ? 1 : session[:loan][:payments].last.id + 1
    if @payment.valid?
      session[:loan][:payments] ||= []
      session[:loan][:payments] << @payment
      @payment = @loan.payments.last.dup
      @payment.date = @payment.date + (12 / @loan.payments_per_year).months
    end
    render :partial => "new"
  end

  def update
    @loan = Loan.new(session[:loan])
    @payment = @loan.payments.new(params[:payment])
    @payment.id = session[:loan][:payments].last.id + 1
    if @payment.valid?
      session[:loan][:payments].delete_if { |payment| payment.id == params[:id].to_i }
      session[:loan][:payments] << @payment
      @payment = @loan.payments.last.dup
      @payment.date = @payment.date + (12 / @loan.payments_per_year).months
      render :partial => "new", notice: 'Payment was successfully updated.'
    else
      render :partial => "edit"
    end
  end

  def destroy
    @loan = Loan.new(session[:loan])
    @payment = @loan.payments.new(params[:payment])
    session[:loan][:payments].delete_if { |payment| payment.id == params[:id].to_i }
    @payments = session[:loan][:payments]
    render :partial => "actual"
  end
end
