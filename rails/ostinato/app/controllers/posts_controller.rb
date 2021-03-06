class PostsController < ApplicationController
  before_action :authenticate_user!
  before_filter :load_parent
  before_action :set_post, only: %i[show edit update destroy]
  before_action :authenticate_author!, only: %i[edit update destroy]

  # GET /posts
  # GET /posts.json
  def index
    @posts = @topic.posts.order('updated_at DESC')
  end

  # GET /posts/1
  # GET /posts/1.json
  def show; end

  # GET /posts/new
  def new
    @post = @topic.posts.new
  end

  # GET /posts/1/edit
  def edit; end

  # POST /posts
  # POST /posts.json
  def create
    @post = @topic.posts.new(post_params)
    @post.user_id = current_user.id

    respond_to do |format|
      if @post.save
        format.html { redirect_to [@topic, @post], notice: I18n.t('posts.post_created') }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to [@topic, @post], notice: I18n.t('posts.post_updated') }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html { render :edit }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html do
        redirect_to topic_posts_path(@topic),
        notice: I18n.t('posts.post_deleted')
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = @topic.posts.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def post_params
    params.require(:post).permit(:title, :content)
  end

  def load_parent
    @topic = Topic.find(params[:topic_id])
  end

  def authenticate_author!
    authenticate_user!
    unless current_user.id == @post.user.id || current_user.is_admin?
      flash[:alert] = I18n.t('posts.only_author')
      redirect_to root_path
    end
  end
end
