class CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_campaign, only: [:show, :destroy, :send_out]

  def new
    @profiles = current_user.profiles_not_contacted.where.not(id: params[:fi]).limit(100) & current_user.profiles_not_in_campaigns
    if @profiles.empty?
      redirect_to user_root_path, alert: 'There is no emails to create campaign. Mine some first.'
    end
    @campaign = current_user.campaigns.new

    @email_templates = current_user.email_templates
  end

  def index
    @campaigns = current_user.campaigns
  end

  def create
    ids = current_user.campaigns.pluck(:profiles_ids).flatten
    fi = JSON(campaign_params[:hidden])['fi'] || []
    @profiles = current_user.profiles_not_contacted.where.not(id: ids + fi).limit(100).ids
    @campaign = current_user.campaigns.create(profiles_ids: @profiles,
                                              name: campaign_params[:name],
                                              email_template_id: current_user.email_templates.find(campaign_params[:email_template_id]).id,
                                              subject: campaign_params[:subject])
    @campaign.send_out if campaign_params[:send_later] == '0'
    render :show
  end
  def send_out
    @campaign.send_out
    redirect_to campaigns_path
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
  def campaign_params
    params.permit(:name, :email_template_id, :hidden, :subject, :send_later)
  end
end
