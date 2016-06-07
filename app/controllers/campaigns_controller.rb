class CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_campaign, only: [:show, :destroy]

  def new
    @profiles = current_user.profiles_not_contacted.where.not(id: params[:fi]).limit(100) & current_user.profiles_not_in_campaigns
    if @profiles.empty?
      redirect_to current_user, alert: 'There is no emails to create campaing. Mine some first.'
    end

    @email_templates = current_user.email_templates
  end

  def index
    @campaigns = current_user.campaigns
  end

  def create
    ids = current_user.campaigns.pluck(:profiles_ids)
    fi = params[:fi] || []
    @profiles = current_user.profiles_not_contacted.where.not(id: (ids + fi).flatten).limit(100)
    @campaign = current_user.campaigns.create(profiles_ids: @profiles.ids,
                                              name: params[:campaign_name],
                                              email_template_id: current_user.email_templates.find(params[:email_template_id]).id)
    @campaign.send_campaign if params[:send_now]
    render :show
  end

  def show

  end

  def destroy
    @campaign.destroy
    redirect_to campaigns_path, notice: 'Campaign was successfully destroyed.'
  end

  private
  def set_campaign
    @campaign = current_user.campaigns.find(params[:id])
  end
end
