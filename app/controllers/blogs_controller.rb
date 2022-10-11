# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_blog, only: %i[show edit update destroy]
  before_action :verify_access_right_of_blog, only: %i[show]
  before_action :verify_blog_owner, only: %i[edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit; end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog.destroy!

    redirect_to blogs_url, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_blog
    @blog = Blog.find(params[:id])
  end

  def blog_params
    filter_list = %i[title content secret]
    filter_list.push(:random_eyecatch) if current_user.premium
    params.require(:blog).permit(filter_list)
  end

  def verify_blog_owner
    raise ActiveRecord::RecordNotFound, '該当ブログが見つかりませんでした' unless @blog.owned_by?(current_user)
  end

  def verify_access_right_of_blog
    raise ActiveRecord::RecordNotFound, '該当ブログが見つかりませんでした' unless verify_blog_owner || !@blog.secret
  end
end
