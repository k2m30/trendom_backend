class ProfilesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:find]
  before_action :authenticate_user!, except: [:find]
  before_action :set_user, only: [:find]

  def find
    logger.warn params
    if @user.nil?
      render nothing: true, status: :unauthorized
    else
      respond_to do |format|
        format.json { render json: Profile.get_emails_available(person_params) }
      end
    end
  end

  private
  def person_params
    params.permit! #(:name, :linkedin_id, :position, :location, :industry, :email)
  end

  def set_user
    if params[:uid].present? and params[:email].present?
      @user = User.find_by(uid: params[:uid], email: params[:email]) || User.create_with_uid_and_email(uid: params[:uid], email: params[:email])
    else
      nil
    end
  end
end
