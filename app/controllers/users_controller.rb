class UsersController < ApplicationController
  before_action :authenticate_user!
  skip_before_filter :verify_authenticity_token, only: [:download]
  def show
  end

  def download
    redirect_to :show
  end
end
