class ProfilesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:get_emails_available]

  def get_emails_available
    logger.warn params
    set_user
    if @user.nil?
      render nothing: true, status: :unauthorized
    else
      render json: Profile.get_emails_available(person_params)
    end
  end

  private
  def person_params
    params.permit! #(:name, :linkedin_id, :position, :location, :industry, :email)
  end

  def set_user
    if params[:uid].present? and params[:email].present?
      @user = User.find_by(uid: params[:uid], email: params[:email]) || User.create_with_uid_and_email(params[:uid], params[:email])
    else
      nil
    end
  end
end
