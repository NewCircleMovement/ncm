class PagesController < ApplicationController

  def index
    @epicenters = Epicenter.all
    @sprouts_count = Epicenter.where(:manifested => false).where(:growing => true).count
    @seed_count = Epicenter.where(:manifested => false).where(:growing => false).count
    @projects_count = Epicenter.where(:manifested => true).count
    @left_info = @mother.information.where(:position => INFORMATION_POSITIONS[:left]).first
    @right_info = @mother.information.where(:position => INFORMATION_POSITIONS[:right]).first
  end

  def info
    @epicenters = Epicenter.all
    @users = User.all
  end

end
