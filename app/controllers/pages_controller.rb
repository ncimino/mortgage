class PagesController < ApplicationController

  # GET /pages/1
  # GET /pages/1.json
  def show
    if params[:id] == 0
      @page = Page.find_by_name('home') || Page.first
    else
      @page = Page.find(params[:id])
    end

    if @page
      # show.html.erb
    else
      redirect_to :admin_root
    end
        
  end

end
