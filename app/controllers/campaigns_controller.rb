class CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profiles, only: [:new, :create]

  def new
    @email_templates = current_user.email_templates
  end

  def create
    @campaign = current_user.campaigns.create(profiles_ids: @profiles.ids,
                                              name: params[:campaign_name], email_template_id: current_user.email_templates.find(params[:email_template_id]).id)
    @campaign.send_campaign if params[:send_now]
    # redirect_to campaigns_path(@campaign)
    render :show
  end

  def show
    @campaign = current_user.campaigns.find(params[:id])
  end

  def destroy
  end

  private
  def set_profiles
    @profiles = current_user.profiles_not_contacted.where.not(id: params[:fi]).limit(100)
  end
end
