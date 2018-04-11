class RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters
  before_filter :new_membership, only: [:new]

  protected

  def new_membership
    request = session[:new_ncm_membership]
    
    if request
      @request_t = request['t'].to_time
      minutes_ago = ((Time.now - @request_t) / 1.minute)

      if minutes_ago < 3
        @child = Epicenter.find_by_slug(request['epicenter_id'])
        @child_membership = @child.memberships.find(request['membership_id'])
        @memberships = Epicenter.grand_mother.memberships.where("monthly_gain >= ?", @child_membership.monthly_fee)
      else
        session.delete(:new_ncm_membership)
      end
    end
  end


  def after_sign_up_path_for(resource)
    "/epicenters/#{Epicenter.grand_mother.slug}/subscriptions/new"
  end


  # custom fields are :name
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:name, :email, :password, :password_confirmation)
    end
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:name, :email, :password, :password_confirmation, :current_password)
    end
  end

end