class EpipagesController < ApplicationController
  before_action :set_epicenter

  def index
    
  end

  def show

  end

  def set_epicenter
  	@epicenter = Epicenter.find_by_slug(params[:epicenter_id])
  end

end

