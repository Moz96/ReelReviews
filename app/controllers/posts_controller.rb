require_relative '../../lib/create_place_helper'

class PostsController < ApplicationController
  before_action :set_post, only: [:show]
  skip_before_action :authenticate_user!, only: :show

  def index
    @posts = current_user.posts.order('created_at DESC')
  end

  def new
    @post = Post.new
  end

  def create
    @place = create_place_helper(params[:google_place_id])

    @post = Post.new(
      user_id: current_user.id,
      place_id: @place.id,
      video_url: post_params['video_url'],
      video_public_id: post_params['video_public_id'],
      place_rating: post_params['place_rating']
      )

    if @post.save!
      redirect_to places_path, notice: 'Post created successfully.'
    else
      render :new
    end
  end

  def show
    @comments = @post.comments
  end

  def next_batch
    last_post_id = params[:after_post_id]
    @posts = Post.where('id > ? AND place_id = ?', last_post_id, params[:place_id]).limit(5)
    # We specify the format as HTML because Rails searches for JSON partials by default when they are rendered via AJAX.
    render partial: 'next_batch', layout: false, formats: [:html]
  end

  private

  def post_params
    params.require(:post).permit(:google_place_id, :place_rating, :video_url, :video_public_id)
  end

  def set_post
    @post = Post.find(params[:id])
  end
end
