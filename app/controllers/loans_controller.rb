class LoansController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :new, :create, :summary, :ideal_schedule, :actual_payments,
                                                 :save_session, :current_schedule]

  def save_session
    session[:loan] = params[:loan]
    render :nothing => true
  end

  def summary
    @loan = Loan.new(params[:loan])
    render :partial => "summary"
  end

  def index
    if user_signed_in?
      @loans = current_user.loans
    else
      redirect_to new_loan_path
    end
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
    render "calculator"
  end

  def show
    @loan = current_user.loans.find(params[:id])
    if @loan.payments.last
      @payment = @loan.payments.last.dup
      @payment.date = @payment.date + (12 / @loan.payments_per_year).months
    else
      @payment = @loan.payments.new
      @payment.date = @loan.first_payment
    end
    @payments = @loan.payments
    render "calculator"
  end

  def create
    if user_signed_in?
      @loan = current_user.loans.new(params[:loan])
      if @loan.save
        #if params[:loan][:payments]
        #  @loan.payments.save
        #end
        flash[:notice] = 'Loan was successfully created.'
        session[:loan] = nil
      else
        session[:loan] = params[:loan]
      end
      render "calculator"
    else
      session[:loan] = params[:loan]
      redirect_to user_session_path, notice: 'You must be signed in to save.'
    end
  end

  def update
    @loan = current_user.loans.find(params[:id])
    if @loan.update_attributes(params[:loan])
      @payment = @loan.payments.last.dup
      @payment.date = @payment.date + (12 / @loan.payments_per_year).months
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
