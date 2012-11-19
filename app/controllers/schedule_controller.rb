class ScheduleController < ApplicationController

  def actual
    if params[:loan][:id].nil? || params[:loan][:id].empty?
      @loan = params[:loan] ? Loan.new(params[:loan]) : Loan.new(session[:loan])
    else
      @loan = Loan.find(params[:loan][:id])
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
