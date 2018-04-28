# == Schema Information
#
# Table name: resource_requests
#
#  id           :integer          not null, primary key
#  requester_id :integer
#  holder_id    :integer
#  resource_id  :integer
#  postit_id    :integer
#  amount       :integer
#  accepted     :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class ResourceRequestsController < ApplicationController
  before_action :set_epicenter

  def new
  end

  def edit
  end


  def create
    @postit = Postit.find(params['postit_id'])
    fruittype = @postit.epicenter.fruittype

    fruit_amount = current_user.fruitbasket.fruit_amount(fruittype)

    if fruit_amount >= @postit.asking
      @request = ResourceRequest.find_or_create_by(
        :requester_id => params['requester_id'],
        :holder_id => params['holder_id'],
        :postit_id => params['postit_id'],
        :resource_id => params['resource_id'],
        :amount => @postit.asking
      )
      message = "You made a request to give #{@postit.asking} #{fruittype.name} for the resource."
    else
      message = "You don't have #{@postit.asking;} #{fruittype.name} to offer for the resource."
    end
    redirect_to epicenter_postits_path(@epicenter), notice: message
  end


  def update
    
    gave_fruit = false

    @request = ResourceRequest.find_by(id: params['id'])

    @epicenter = Epicenter.find_by_slug(params['epicenter_id'])

    @receiver = User.find(@request.requester_id)
    @giver = User.find(@request.holder_id)
    @resource = Resource.find(@request.resource_id)

    if @request.amount > 0
      gave_fruit = @receiver.give_fruit_to(@giver, @epicenter.fruittype, @request.amount)
      if gave_fruit
        @request.accepted = true
        @request.save
      end
    else
      @request.accepted = true
      @request.save
    end

    if @request.accepted
      @resource.owner = @receiver
      @resource.save

      postit = @request.postit
      postit.fruitbasket.give_fruit_to(@giver.fruitbasket, @epicenter.fruittype, postit.visibility)
      postit.visibility = 0
      postit.owner = @receiver
      postit.save
      
      # set other requests for this resource to false
      @resource.resource_requests.where.not(:id => @request.id).each do |other|
        other.accepted = false
        other.save
      end

      redirect_to params[:back], notice: "You accepted a #{@request.amount} #{@epicenter.fruittype.name} transfer from #{@receiver.name}"
    else
      if gave_fruit
        message = "You received #{@request.amount} #{@epicenter.fruittype.name} from #{@receiver.name} but the resource was not transferred !"
      else
        message = "#{@receiver.name} did not have enought #{@epicenter.fruittype.name} for the transfer"
      end
      redirect_to params[:back], notice: message
    end

    
    
    
  end

  def destroy
    # @resource.destroy
    redirect_to epicenter_resources_path(@epicenter)

  end


  private

  def set_epicenter
    @epicenter = Epicenter.find_by_slug(params[:epicenter_id])
  end


  def resource_params
    params.require(:resource_request).permit(:requester_id, :holder_id, :postit_id, :resource_id)
  end

end

