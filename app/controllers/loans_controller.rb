class LoansController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :create]

  def index
    @loans = current_user.loans
  end

  def show
    @loan = current_user.loans.find(params[:id])
  end

  def new
    #@loan = Loan.new
    #@loan = session[:loan] ? Loan.new(session[:loan]) : Loan.new
    if session[:loan]
      @loan = Loan.new(session[:loan])
    else
      @loan = Loan.new
      @loan.payments_per_year = 12
      @loan.interest_rate = "5.000"
    end
  end

  def edit
    @loan = current_user.loans.find(params[:id])
  end

  def create
    if user_signed_in?
      @loan = current_user.loans.new(params[:loan])
      flash[:notice] = 'Loan was successfully created.' if @loan.save
      render action: "edit"
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
    render action: "edit"
  end

  def destroy
    @loan = current_user.loans.find(params[:id])
    @loan.destroy
    redirect_to loans_url
  end
end
