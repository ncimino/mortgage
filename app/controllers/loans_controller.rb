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
    @loan = session[:loan] ? Loan.new(session[:loan]) : Loan.new
  end

  def edit
    @loan = current_user.loans.find(params[:id])
  end

  def create
    if user_signed_in?
      @loan = current_user.loans.new(params[:loan])
      if @loan.save
        redirect_to @loan, notice: 'Loan was successfully created.'
      else
        render action: "new"
      end
    else
      session[:loan] = params[:loan]
      redirect_to user_session_path, notice: 'You must be signed in to save.'
    end
  end

  def update
    @loan = current_user.loans.find(params[:id])
    if @loan.update_attributes(params[:loan])
      redirect_to @loan, notice: 'Loan was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @loan = current_user.loans.find(params[:id])
    @loan.destroy
    redirect_to loans_url
  end
end
