# == Schema Information
#
# Table name: fruittypes
#
#  id            :integer          not null, primary key
#  name          :string
#  monthly_decay :float
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  epicenter_id  :integer
#

class FruittypesController < MainEpicentersController
  before_action :set_epicenter
  before_action :set_fruittype, only: [:edit, :update, :destroy]
  before_action :require_caretaker

  def index
  end

  def new
    @sow = params[:sow]
    if @sow and @epicenter.fruittype
      redirect_to epicenter_edit_engagement_path(@epicenter, :sow => true), notice: "Frugtypen #{@epicenter.fruittype.name} er allerede oprettet. Udfør Step 2."
    end
    @fruittype = Fruittype.new
  end

  def edit
  end


  def create
    @sow = params[:sow]
    @fruittype = Fruittype.new(fruittype_params)
    @fruittype.epicenter_id = @epicenter.id
    
    if @fruittype.save
      # if sowing the seed, redirect to Trin 2 (Opbakning) after saving
      if params[:sow]
        redirect_to epicenter_edit_engagement_path(@epicenter, :sow => true)
      else
        redirect_to epicenter_fruittypes_path(@epicenter), notice: 'Frugttypen blev oprettet'
      end
    else
      render action: 'new', :sow => @sow
    end

  end

  def update
    if @fruittype.update(fruittype_params)
      redirect_to epicenter_fruittypes_path(@epicenter), notice: 'Frugttypen blev opdateret.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @fruittype.destroy
    redirect_to epicenter_fruittypes_path(@epicenter)
  end


  private
    def set_epicenter
      @epicenter = Epicenter.find_by_slug(params[:epicenter_id])
      @pages = @epicenter.epipages
    end

    def set_fruittype
      @fruittype = Fruittype.find(params[:id])
    end

    def fruittype_params
      params.require(:fruittype).permit(:name, :monthly_decay, :epicenter_id)
    end

end
