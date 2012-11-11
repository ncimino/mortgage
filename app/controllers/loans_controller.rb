class LoansController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :create, :summary, :schedule]

  def new_payment_form
    @loan = Loan.find(params[:id])
    @payment = Payment.new
    render :partial => "new_payment_form"
  end

  def summary
    @loan = Loan.new(params[:loan])
    render :partial => "summary"
  end

  def schedule
    @loan = Loan.new(params[:loan]);
    #@schedule = @loan.schedule;
    render :partial => "schedule"
  end

  def payments
    @loan = Loan.new(params[:loan]);
    @payments = @loan.payments
    @payment = Payment.new
    #@schedule = @loan.schedule;
    render :partial => "payments"
  end

  def index
    @loans = current_user.loans
  end

  def new
    if session[:loan]
      @loan = Loan.new(session[:loan])
    else
      @loan = Loan.new
      @loan.payments_per_year = 12
      @loan.interest_rate = "5.000"
      @loan.escrow_payment = "0.00"
      @loan.first_payment = Time.now.to_date
    end
    @payment = Payment.new
    render "calculator"
  end

  def show
    @loan = current_user.loans.find(params[:id])
    @payment = Payment.new
    #@schedule = @loan.schedule
    render "calculator"
  end

  def edit
    @loan = current_user.loans.find(params[:id])
    @payment = Payment.new
    #@schedule = @loan.schedule
    render "calculator"
  end

  def create
    if user_signed_in?
      @loan = current_user.loans.new(params[:loan])
      flash[:notice] = 'Loan was successfully created.' if @loan.save
      render "calculator"
      session[:loan] = nil
    else
      session[:loan] = params[:loan]
      redirect_to user_session_path, notice: 'You must be signed in to save.'
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
