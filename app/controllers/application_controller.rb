class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :get_mother_id
  before_filter :get_mother

  def get_mother_id
  	@mother_id = Epicenter.grand_mother.id
  end

  def get_mother
    @mother = Epicenter.grand_mother
  end

  protected
    
    def after_sign_in_path_for(resource)
      ticket_path = get_ticket_path
      ticket_path || root_path
    end

    def after_sign_up_path_for(resource)
      ticket_path = get_ticket_path
      ticket_path || "/epicenters/#{Epicenter.grand_mother.slug}/subscriptions/new"
    end


    def get_ticket_path
      ticket_request = session[:ticket]
      if ticket_request.present?
        t = ticket_request['t'].to_time
        minutes_ago = ((Time.now - t) / 1.minute)
        session.delete(:ticket)
        if minutes_ago < 3
          @epicenter = Epicenter.find_by_slug(ticket_request['epicenter_id'])
          return new_epicenter_ticket_path(@epicenter)
        end
      end    
      return nil
    end

end
