class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_post, only: [:show, :destroy]
  before_action :check_img, only: [:create]
  
  def index
    @posts = Post.paginate(:page => params[:page], :per_page => 5).includes(:photos, :user, :likes).
      order(created_at: :DESC)
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      if params[:images]
        params[:images].keys.each do |img|
          @post.photos.create(image: params[:images][img] )
        end
      end
    
      redirect_to posts_path, notice: 'Saved'
    else
      redirect_to posts_path, alert: 'Something went wrong ...'
    end
  end

  def show
    @photos = @post.photos
    @likes = @post.likes.includes(:user)
    @comment = Comment.new
    @is_liked = @post.is_liked(current_user)
    @is_bookmarked = @post.is_bookmarked(current_user)
  end

  def destroy
    if @post.user == current_user
      if @post.destroy
        flash[:notice] = "Post deleted!"
      else
        flash[:alert] = "Something went wrong ..."
      end
    else
      flash[:notice] = "You don't have permission to do this!"
    end
  end 

  private

  def find_post
    @post = Post.find_by id: params[:id]

    return if @post
    flash[:danger] = "Post not exist!"
    redirect_to root_path
  end

  def check_img
    if params[:images].keys.empty?
      flash[:danger] = "Post not exist!"
    redirect_to root_path
    end
  end

  def post_params
    params.require(:post).permit(:content)
  end
end