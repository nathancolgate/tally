# Used only for ajax create/edit/destroy methods
# all viewing is done in polls controller
class ChoicesController < ApplicationController
  before_filter :ajax_required
  layout nil

  def create
    @choice = Choice.new @params[:choice]
    @choice.poll = @poll
    return render_error_on('choice') unless @choice.save
    render_partial 'choice'
  end

  def edit
    @choice.update_attributes(@params[:choice])
    return render_error_on('choice') unless @choice.valid?
    render_partial 'choice'
  end

  def destroy
    begin
      @choice.destroy
      render :text => 'deleted.' '200 OK'
    rescue
      render :status => '500 ERROR'
    end
  end
  
  protected
  # all actions require at least a visitor
  def protect?(action)
    true
  end
  
  def authorize?(user, action)
    return false unless visitor?
    return authorize_create?(user) if action == 'create'
    authorize_edit_and_destroy?(user)
  end
  
  def authorize_create?(user)
    begin
      @poll = Poll.find @params[:poll_id]
      return user.can_edit?(@poll)
    rescue
      return false
    end
  end
  
  def authorize_edit_and_destroy?(user)
    @choice = Choice.find :first, :conditions => ['choices.id = ?', @params[:id]], :include => :poll
    return false unless @choice
    user.can_edit?(@choice)
  end
end
