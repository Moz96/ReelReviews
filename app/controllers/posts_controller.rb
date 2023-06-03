class PostsController < ApplicationController
  before_action :set_post, only: [:show]
  def index
    @posts = Post.all
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user
    if @post.save!
      redirect_to root
    else
      flash.now[:alert] = 'Reel could not be uploaded'
    end
  end

  def show
    @comments = posts.comments
  end

  private

  def post_params
    params.require.(:post).permit(:user_id, :place_id, :place_rating)
  end

  def set_post
    @post = Post.find(params[:id])
  end
end
