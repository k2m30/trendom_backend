require 'open-uri'
# require 'test_helper'

class TestsController < ApplicationController
  def index
    @email = params[:email]
    @uid = params[:uid]
    @data = params[:data]
  end
end
