class CommentsController < ApplicationController
  def new
    @post = Post.find(params[:post_id])
    @comment = Comment.new(post: @post)

    respond_to do |format|
      format.html {
        # Handle regular HTML request
        render partial: 'comments/form', locals: { comment: @comment }
      }
      format.js {
        # Handle AJAX request
        render partial: 'comments/form', locals: { comment: @comment }
      }
    end
  end

  def create
    @post = Post.find(params[:post_id])
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    respond_to do |format|
      if @comment.save
        format.html { redirect_to post_path(@post), notice: 'Comment created successfully.' }
        format.js { render partial: 'comments/comment', locals: { comment: @comment } }
      else
        format.html { redirect_to post_path(@post), alert: 'Failed to create comment.' }
        format.js { render partial: 'comments/error', status: :unprocessable_entity }
      end
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:text)
  end
end
