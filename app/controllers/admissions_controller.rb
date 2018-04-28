# == Schema Information
#
# Table name: admissions
#
#  id           :integer          not null, primary key
#  name         :string
#  description  :text
#  price        :integer
#  start_t      :datetime
#  end_t        :datetime
#  epicenter_id :integer
#  n_max        :integer
#  n_actual     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class AdmissionsController < MainEpicentersController

  before_action :set_epicenter
  before_action :set_admission, only: [:show, :edit, :update, :destroy]
  before_action :require_caretaker, only: [:edit, :index]
  

  def index
    @admissions = @epicenter.admissions
    @hard_currency = (@epicenter == @mother)
  end

  def show
  end

  def new
    @admission = @epicenter.admissions.build
  end

  def edit
  end

  def create
    @admission = @epicenter.admissions.build(admission_params)
    if @admission.save
      if params[:sow]
        redirect_to epicenter_edit_meeting_time_path(@epicenter, :sow => true)
      else
        redirect_to epicenter_admissions_path(@epicenter), notice: 'Medlemskabet blev oprettet'
      end
    else
      render action: 'new'
    end
  end
  

  def update
    @admission.n_actual = @admission.users.count

    if @admission.update(admission_params)
      redirect_to epicenter_admissions_path(@epicenter), notice: 'Medlemskabet blev opdateret.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @admission.destroy
    redirect_to epicenter_admissions_path(@epicenter)
  end


  private
    def set_epicenter
      @epicenter = Epicenter.find_by_slug(params[:epicenter_id])
      @pages = @epicenter.epipages
    end

    def set_admission
      @admission = Admission.find(params[:id])
    end

    def admission_params
      params.require(:admission).permit(:name, :description, :price, :start_t, :end_t, :n_max, :n_actual)
    end

end
