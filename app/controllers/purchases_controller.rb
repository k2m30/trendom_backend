class PurchasesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:index]
  def index
    logger.warn params
    redirect_to root_path, notice: params
  end
end
