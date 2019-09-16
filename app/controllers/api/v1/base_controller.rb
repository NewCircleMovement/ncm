class Api::V1::BaseController < ApplicationController

    skip_before_action :verify_authenticity_token
    before_filter :authenticate_token!
	
    # before_filter :parse_request, :authenticate_user_from_token!
	# before_filter :parse_request

	# def validate_json(condition)
 #  	unless condition
 #    	render nothing: true, status: :bad_request
 #  	end
	# end

	# def update_values(ivar, attributes)
 #  	instance_variable_get(ivar).assign_attributes(attributes)
 #  	if instance_variable_get(ivar).save
 #    	render nothing: true, status: :ok
 #  	else
 #    	render nothing: true, status: :bad_request
 #  	end
	# end

	# def check_existence(ivar, object, finder)
 #  	instance_variable_set(ivar, instance_eval(object+"."+finder))
	# end


  private

    # def authenticate_user_from_token!
    #   if !@json['api_token']
    #     render nothing: true, status: :unauthorized
    #   else
		  #   @epicenter = nil
    #     Epicenter.find_each do |u|
    #      	if Devise.secure_compare(u.api_token, @json['api_token'])
    #       	@epicenter = u
    #       end
    #     end
    #   end
    # end

    def authenticate_token!
        url = request.original_url

        return true if @epicenter
        return true if url.include?('api/v1/stripe/')

        
        epicenter_slug = url.split('api/v1/epicenters/')[-1].split('/')[0]

        authenticate_with_http_token do |token, options|
            @epicenter = Epicenter.find_by(:api_token => token, :slug => epicenter_slug)
        end

        if !@epicenter
            render nothing: true, status: :unauthorized
        end
            
    end

    # def parse_request
    #   @json = JSON.parse(request.body.read)
    # end

end
