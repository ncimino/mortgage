class ScheduleController < ApplicationController

  def get_session_payments
    @payments = []
    if session[:payments]
      session[:payments].each { |p|
        this_payment = @loan.payments.new(p)
        this_payment.id = p[:id]
        @payments << this_payment
      }
      @payments.sort! { |a,b| a.date <=> b.date }
    end
  end

  def actual
    if params[:loan][:id].nil? || params[:loan][:id].empty?
      @loan = params[:loan] ? Loan.new(params[:loan]) : Loan.new(session[:loan])
      get_session_payments
    else
      @loan = Loan.includes(:payments).find(params[:loan][:id])
    end
    @schedule = Schedule.new(@loan).actual
    render :partial => "schedule"
  end

  def ideal
    @loan = Loan.new(params[:loan])
    @loan.id = params[:loan][:id]
    @schedule = Schedule.new(@loan).ideal
    render :partial => "schedule"
  end

end
