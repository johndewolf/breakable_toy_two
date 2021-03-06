class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    user_path(@user)
  end

  before_filter :set_search

  def set_search
    @q= Goal.search(params[:q])
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << [:first_name, :last_name]
  end
end
