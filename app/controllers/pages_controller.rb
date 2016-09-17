class PagesController < ApplicationController

  def index
    @epicenters = Epicenter.all
  end


end
