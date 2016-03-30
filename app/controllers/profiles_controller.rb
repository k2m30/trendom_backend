class ProfilesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:find, :download]
  before_action :authenticate_user!, except: [:find]

  def find
    logger.warn params
    set_user

    if @user.nil?
      render nothing: true, status: :unauthorized
    else
      respond_to do |format|
        format.json { render json: Person.get_emails(person_params) }
      end
    end
  end

  def download

  end

  private
  def person_params
    params.permit!#(:name, :linkedin_id, :position, :location, :industry, :email)
  end

  def set_user
    @user = User.find_by(uid: params[:uid], email: params[:email])
  end
end
