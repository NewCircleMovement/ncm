# == Schema Information
#
# Table name: postits
#
#  id             :integer          not null, primary key
#  resource_id    :integer
#  owner_id       :integer
#  owner_type     :string
#  wall_id        :integer
#  visibility     :integer
#  asking         :integer          default(0)
#  only_epicenter :boolean          default(FALSE)
#  title          :string
#  body           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class PostitsController < ApplicationController
  before_action :set_epicenter
  before_action :find_postit, only: [:show, :edit, :update, :destroy]

  def index
    @up = false

    if @sort
      @sort_field = if @sort == "asking" then "asking" else "visibility" end
    else
      @sort_field = "visibility"
    end

    if params[:dir].present?
      @dir = params[:dir]
      @up = if params[:dir] == 'up' then true else false end
    end

    @kind = if params[:kind].present? then params[:kind] else nil end
    @search = if params[:search].present? then params[:search] else nil end
    @sort = if params[:sort].present? then params[:sort] else nil end 
    @sort_direction = if @up then "ASC" else "DESC" end

    @postits = @epicenter.postits.where(:only_epicenter => false).where.not(:visibility => 0)
    @postits = if @search then @postits.search_for(@search) else @postits end

    if @kind
      if @kind == 'notify'
        @postits = @postits.where(:resource_id => nil)
      else
        @postits = @postits.where.not(:resource_id => nil)
        case @kind
        when 'exchange'
          @postits = @postits.where.not(:asking => 0)
        when 'giveaway'
          @postits = @postits.where(:asking => 0)
        end
      end
    end

    @postits = @postits.order("#{@sort_field} #{@sort_direction}")
  end

  def show
  end

  def new
    @postit = Postit.new
    @resources = current_user.resources
  end

  def create
    @postit = current_user.postits.build(postit_params)
    @postit.epicenter_id = @epicenter.id
    
    if @postit.save
      postit_basket = Fruitbasket.find_or_create_by(:owner_id => @postit.id, :owner_type => @postit.class)
      fruittype = @epicenter.fruittype
      amount = @postit.visibility
      
      success = current_user.fruitbasket.give_fruit_to(postit_basket, fruittype, amount)

      if success
        message = "You PostIt was created. You spent #{amount} #{fruittype.name} on visibility"
      else
        message = "You don't have enough #{fruittype.name} to give a visibility of #{amount}"
      end

      redirect_to epicenter_postits_path(@epicenter), notice: message
    else
      render action: 'new'
    end
  end


  def edit
    @resources = current_user.resources
  end


  def update
    success = false
    old_visibility = @postit.visibility
    new_visibility = postit_params[:visibility].to_i

    change_in_visibility = new_visibility - old_visibility 

    if change_in_visibility > 0
      # new visibility is higher and user must transfer fruits
      success = current_user.fruitbasket.give_fruit_to(@postit.fruitbasket, @fruittype, change_in_visibility)
      if success
        message = "Visibility was increased with #{change_in_visibility} #{@fruittype.name}"
      else
        message = "Not enough #{fruittype.name} to increase visibility with #{change_in_visibility}"
      end
    elsif change_in_visibility < 0
      # new visibility is lower and user will get difference back
      success = @postit.fruitbasket.give_fruit_to(current_user.fruitbasket, @fruittype, -change_in_visibility)
      if success
        message = "Visibility was reduced. You got #{-change_in_visibility} #{@fruittype.name} back"
      else
        message = "Visibility was not reduced"
      end
    elsif change_in_visibility == 0
      success = true
      message = "Visibility was not changed"
    end

    if success
      if @postit.update(postit_params)
        redirect_to epicenter_postits_path(@epicenter), notice: "Your PostIt was updated. #{message}"
      else
        render action: 'edit'
      end
    else
      render action: 'edit', notice: "Your PostIt was NOT updated. #{message}"
    end
  end


  def destroy
    message = 'Your PostIt was deleted'
    residual_fruit = @postit.fruitbasket.fruit_amount(@fruittype)
    
    if residual_fruit
      success = @postit.fruitbasket.give_fruit_to(current_user.fruitbasket, @fruittype, residual_fruit)
      if success
        message = "Your PostIt was deleted and #{residual_fruit} #{@fruittype.name} was given back to you."
      end
    end

    @postit.destroy
    redirect_to epicenter_postits_path(@epicenter), notice: message
  end


  private

  def set_epicenter
    @epicenter = Epicenter.find_by_slug(params[:epicenter_id])
    @fruittype = @epicenter.fruittype
  end

  def find_postit
    @postit = Postit.find(params[:id])
  end

  def postit_params
    params.require(:postit).permit(:resource_id, :title, :body, :visibility, :asking, :only_epicenter)
  end

end
