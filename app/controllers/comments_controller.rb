class CommentsController < ApplicationController
  def new
    @comment = Comment.new
  end

  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save!
      redirect_to post_path
    else
      flash.now[:alert] = 'Comment could not be created'
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:text)
  end
end
