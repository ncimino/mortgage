class PaymentsController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :create, :summary, :schedule, :summary]

  def index
    @loan = Loan.find(params[:loan_id])
    @payments = Payment.all
  end

  def new
    @loan = Loan.find(params[:loan_id])
    #@payment = Payment.new
    @payment = @loan.payments.last.dup
    @payment.date = @payment.date + (12 / @loan.payments_per_year).months
    render :partial => "form"
  end

  def show
    @payment = Payment.find(params[:id])
    #@loan = Loan.find(params[:loan_id])
    @loan = @payment.loan
  end

  def edit
    #@action = "update"
    #@method = :put
    @payment = Payment.find(params[:id])
    @loan = @payment.loan
    render :partial => "edit_form"
  end

  def create
    @loan = Loan.find(params[:loan_id])
    @payment = @loan.payments.build(params[:payment])
    if @payment.save
      #redirect_to loan_url(@payment.loan_id), notice: 'Payment was successfully created.'
      #@payment = Payment.new
      @payment = @loan.payments.last.dup
      @payment.date = @payment.date + (12 / @loan.payments_per_year).months
      #flash_now[:notice] = 'Payment was successfully created.'
      render :partial => "form", notice: 'Payment was successfully created.'
    else
      #render action: "new"
      render :partial => "form"
    end
  end

  def update
    #@loan = Loan.find(params[:loan_id])
    @payment = Payment.find(params[:id])
    @loan = @payment.loan
    if @payment.update_attributes(params[:payment])
      #redirect_to loan_url(@payment.loan_id), notice: 'Payment was successfully updated.'
      #@payment = Payment.new
      @payment = @loan.payments.last.dup
      @payment.date = @payment.date + (12 / @loan.payments_per_year).months
      #flash_now[:notice] = 'Payment was successfully updated.'
      render :partial => "form", notice: 'Payment was successfully updated.'
    else
      #@action = "update"
      render :partial => "edit_form"
    end
    #render "calculator"
  end

  def destroy
    @payment = Payment.find(params[:id])
    @loan = @payment.loan
    @payments = @loan.payments
    @payment.destroy
    render :partial => "loans/actual_payments"
    #redirect_to loan_url(@payment.loan_id), notice: 'Payment was successfully destroyed.'
    #redirect_to @loan, notice: 'Payment was successfully destroyed.'
  end
end
