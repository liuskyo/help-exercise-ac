class MessagesController < ApplicationController

  before_action :authenticate_user!, :except => [:index, :show]

  def index
    # TODO: fix N+1 queries for user and comments V
    @messages = Message.includes(:user,:comments).order("id DESC").page( params[:page] )

    if params[:status] == "pending"
      # TODO: @messages = @messages.pending V
      @messages = @messages.pending
    elsif params[:status] == "completed"
      # TODO: @messages = @messages.completed V
      @messages = @messages.completed
    end

    if params[:days]
      # TODO: @messages = @messages.within_days(params[:days].to_i)
      @messages = @messages.within_days(params[:days].to_i)
    end

    respond_to do |format|
      format.html
      format.json {
        arr = @messages.map { |t|{ :id => t.id, :title => t.title }}
        render :json => { :data => arr }
       }
    end
  end

  def show
    @message = Message.find( params[:id] )
    @comment = Comment.new
  end

  def new
    @message = Message.new
  end

  def create
    @message = Message.new( message_params )
    @message.user = current_user

    @message.save!

    redirect_to root_path
  end

  def edit
    @message = current_user.messages.find( params[:id] )

    render "new"
  end

  def update
    @message = current_user.messages.find( params[:id] )

    @message.update!( message_params )

    redirect_to message_path(@message)
  end

  def destroy
    @message = current_user.messages.find( params[:id] )
    @message.destroy

    redirect_to root_path
  end

  protected

  def message_params
    params.require(:message).permit(:title, :content, :category_name)
  end

end
