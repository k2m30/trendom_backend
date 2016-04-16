class PurchasesController < ApplicationController
  def index
    logger.warn params
    render nothing: true, status: :ok
  end
end
