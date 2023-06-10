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

  def next_batch
    last_post_id = params[:after_id]
    @posts = Post.where("id > ? AND place_id = ?", last_post_id, params[:place_id]).limit(5)
    render layout: false
  end

  private

  def post_params
    params.require.(:post).permit(:user_id, :place_id, :place_rating, :video)
  end

  def set_post
    @post = Post.find(params[:id])
  end
end
