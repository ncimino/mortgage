class LoansController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :create, :calculations]

  def calculations
    #params[:loan][:id].delete
    @loan = Loan.new(params[:loan])
    render :partial => "calculations"
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
    end
    render "calculator"
  end

  def edit
    @loan = current_user.loans.find(params[:id])
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
