class PagesController < ApplicationController

  def index
    @epicenters = Epicenter.all
  end

  def info
    @epicenters = Epicenter.all
    @users = User.all
  end

end
