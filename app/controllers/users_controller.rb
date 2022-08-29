class UsersController < ApplicationController
  before_action :check_login, except: %i(new create)
  before_action :is_admin, only: :destroy
  before_action :find_user, except: %i(new create index)
  before_action :correct_user, only: %i(edit update)

  def show
    @micro_posts = @user.micro_posts.by_created_at.page(params[:page]).per Settings.per_page
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new create_user_params
    if @user.save
      @user.send_mail_activate
      flash[:success] = t "auths.mail.notice"
      redirect_to root_path
    else
      flash[:danger] = t ".new.signup_fail"
      render :new
    end
  end

  def index
    @user = User.select(:id, :name, :email, :activated)
                .page(params[:page]).per Settings.per_page
  end

  def edit; end

  def update
    if @user.update_attributes update_user_params
      flash[:success] = t "users.edit.update_success"
      redirect_to @user
    else
      flash[:warning] = t "users.edit.update_fail"
      render :edit
    end
  end

  def destroy
    @user.destroy
    flash[:success] = t ".index.delete_success"
    redirect_to users_path
  end

  private

  def create_user_params
    params.require(:user).permit User::CREATE_USERS_PARAMS
  end

  def update_user_params
    params.require(:user).permit User::UPDATE_USERS_PARAMS
  end

  def find_user
    @user = User.find_by id: params[:id]
    return if @user
    flash[:warning] = t ".no_exist"
    redirect_to root_path
  end

  def check_login
    return if logged_in
    store_location
    flash[:warning] = t "auths.not_login"
    redirect_to login_path
  end

  def correct_user
    return if current_user? @user
    flash[:danger] = t "auths.incorrect_user"
    redirect_to root_path
  end

  def is_admin
    return if is_admin?
    flash[:warning] = t "auths.incorrect_user"
    redirect_to users_path
  end
end
