class PaymentsController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :create, :summary, :schedule, :summary]

  def index
    @loan = Loan.find(params[:loan_id])
    @payments = Payment.all
  end

  def new
    @loan = Loan.find(params[:loan_id])
    @payment = Payment.new
    render :partial => "form"
  end

  def show
    @loan = Loan.find(params[:loan_id])
    @payment = Payment.find(params[:id])
  end

  def edit
    @loan = Loan.find(params[:loan_id])
    @payment = Payment.find(params[:id])
  end

  def create
    @loan = Loan.find(params[:loan_id])
    @payment = @loan.payments.build(params[:payment])
    if @payment.save
      #redirect_to loan_url(@payment.loan_id), notice: 'Payment was successfully created.'
      @payment = Payment.new
      render :partial => "form", notice: 'Payment was successfully created.'
    else
      #render action: "new"
      render :partial => "form"
    end
  end

  def update
    @loan = Loan.find(params[:loan_id])
    @payment = Payment.find(params[:id])
    if @payment.update_attributes(params[:payment])
      redirect_to loan_url(@payment.loan_id), notice: 'Payment was successfully updated.'
    else
      render action: "edit"
    end
    render "calculator"
  end

  def destroy
    @payment = Payment.find(params[:id])
    @loan = @payment.loan
    @payments = @loan.payments
    @payment.destroy
    render :partial => "loans/payments_main"
    #redirect_to loan_url(@payment.loan_id), notice: 'Payment was successfully destroyed.'
    #redirect_to @loan, notice: 'Payment was successfully destroyed.'
  end
end
