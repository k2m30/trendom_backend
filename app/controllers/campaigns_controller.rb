class CampaignsController < ApplicationController
  before_action :authenticate_user!

  def new
    @profiles = current_user.profiles_not_contacted.where.not(id: params[:filtered_ids])
    @email_templates = current_user.email_templates
  end

  def create
  end

  def destroy
  end
end
