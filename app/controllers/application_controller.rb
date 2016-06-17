class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :get_mother_id

  def get_mother_id
  	@mother_id = Epicenter.grand_mother.id
  end

end
