class MainEpicentersController < ApplicationController

  def require_caretaker
    if current_user
      unless @epicenter.has_caretaker?(current_user)
        redirect_to epicenters_path, notice: "Du er ikke caretaker af #{@epicenter.name}"
      end
    else 
      redirect_to epicenters_path, notice: "Du er ikke caretaker af #{@epicenter.name}"
    end
  end

end