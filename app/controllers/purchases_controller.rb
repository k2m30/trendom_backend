class PurchasesController < ApplicationController
  before_action :authenticate_user!
  skip_before_filter :verify_authenticity_token, only: [:index]

  def index
    logger.warn params
    if current_user.purchase(params)
      redirect_to root_path, notice: params
    else
      redirect_to root_path, alert: params
    end
  end
end