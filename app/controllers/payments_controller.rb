class PaymentsController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :create, :summary, :schedule]

  def index
    @payments = Payment.all
    render :partial => "payments"
  end

  def new
    @loan = Loan.find(params[:loan_id])
    @payment = @loan.payments.new

    #@payment = Payment.new
    render :partial => "form"
  end

  def show
    @loan = Loan.find(params[:loan_id])
    #@payment = Payment.new
    @payment = @loan.payments.new
    @payments = @loan.payments
    #@payment = Payment.find(params[:id])
    render :partial => "payments"
  end

  def edit
    @loan = Loan.find(params[:loan_id])
    #@payment = Payment.find(params[:id])
    @payment = @loan.payments.find(params[:id])
    render :partial => "form"
  end

  def create
    @loan = Loan.find(params[:loan_id])
    @payment = @loan.payments.new
    if user_signed_in?
      #@payment = Payment.new(params[:loan])
      #flash[:notice] = 'Loan was successfully created.' if @loan.save
      render :partial => "form"
      #session[:loan] = nil
    else
      #session[:loan] = params[:loan]
      #redirect_to user_session_path, notice: 'You must be signed in to save.'
    end
  end

  def update
    @loan = current_user.loans.find(params[:id])
    if @loan.update_attributes(params[:loan])
      flash[:notice] = 'Loan was successfully updated.'
    end
    render "calculator"
  end

  def destroy
    @loan = current_user.loans.find(params[:id])
    @loan.destroy
    redirect_to loans_url
  end
end
