class PaymentsController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :create, :summary, :schedule]
  before_filter :get_loan

  def get_loan
    @loan = Loan.find(params[:loan_id])
  end

  def index
    @payments = Payment.all
  end

  def new
    @payment = Payment.new
    render :partial => "form"
  end

  def show
    @payment = Payment.find(params[:id])
  end

  def edit
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
    @payment.destroy
    redirect_to loan_url(@payment.loan_id), notice: 'Payment was successfully destroyed.'
  end
end
