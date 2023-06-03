class CommentsController < ApplicationController
  def index
    @comments = Comment.all
  end

  def new
    @comment = Comment.new
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.user = current_user
    if @comment.save!
      redirect_to post_path
    else
      flash.now[:alert] = 'Comment could not be created'
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:post_id, :user_id, :text)
  end
end
