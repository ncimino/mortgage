class ApplicationController < ActionController::Base

  before_filter :get_variables

  def get_variables
    @display_pages = Page.order("ordinal")
    #@payment = Payment.new()
  end

  protect_from_forgery
end
