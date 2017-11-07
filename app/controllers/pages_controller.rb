class PagesController < ApplicationController

  def index
    @epicenters = Epicenter.all
    @sprouts_count = Epicenter.where(:manifested => false).where(:growing => true).count
    @seed_count = Epicenter.where(:manifested => false).where(:growing => false).count
    @projects_count = Epicenter.where(:manifested => true).count
    @left_info = @mother.information.where(:position => INFORMATION_POSITIONS[:left]).first
    @right_info = @mother.information.where(:position => INFORMATION_POSITIONS[:right]).first

    @support = @mother.information.where(:title => "Support").first
    @paid = @mother.information.where(:title => "Paid").first
    @pool = @mother.information.where(:title => "Pool").first
    @message = @mother.information.where(:title => "Message").first
  end

  def info
    @epicenters = Epicenter.all
    @users = User.all
  end


end
