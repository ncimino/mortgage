class PaymentsController < ApplicationController
  before_filter :authenticate_user!, :except => [:new, :create, :summary, :schedule]

  def index
    @payments = Payment.all
  end

  def new
    @payment = Payment.new
  end

  def show
    @payment = Payment.find(params[:id])
  end

  def edit
    @payment = Payment.find(params[:id])
  end

  def create
    if user_signed_in?
      @payment = Payment.new(params[:loan][:payment])
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
