class MemberResourcesController < ApplicationController
  before_action :get_resource, :only => [:show, :edit, :update, :destroy]

  def index
    @resources = current_user.resources
  end

  def show
  end

  def edit
    @path = user_member_resource_path(current_user, @resource)
    @method = "put"
  end

  def new
    @resource = current_user.resources.build
    @path = user_member_resources_path(current_user)
    @method = "post"
    @types = ['Item']
    @back = params['back']
  end

  def create
    if params['resource'] and params['resource']['back']
      @back = params['resource']['back']
    end

    @resource = current_user.resources.build(member_resource_params)
    @resource.holder_id = current_user.id

    if @resource.save
      if @back
        redirect_to @back, notice: 'Your resource was created'
      else
        redirect_to user_member_resources_path(current_user), notice: 'Your resource was created'
      end
    else
      render action: 'new'
    end

  end

  def update
    if @resource.update(member_resource_params)
      redirect_to user_member_resources_path(current_user), notice: 'Your resource was saved'
    else
      render action: 'edit'
    end
  end


  def destroy
    @resource.destroy
    redirect_to user_member_resources_path(current_user), notice: 'Your resource was deleted'
  end


  private

  def get_resource
    if params[:id]
      @resource = Resource.find(params[:id])
    elsif params[:item]
      @resource = Resource.find(params[:item][:id])
    end
    # byebug
  end

  def member_resource_params
    if @resource
      case @resource.type
      when "Item"
        permitter = params.require(:item)
      else
        permitter = params.require(:resource)
      end
    else
      permitter = params.require(:resource)
    end
    permitter.permit(:type, :title, :body, :holder_id, :image)
  end

end
