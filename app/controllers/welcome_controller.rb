# encoding: UTF-8
# frozen_string_literal: true

class WelcomeController < ApplicationController
  layout 'landing'
  include Concerns::DisableCabinetUI

  def index
  end

  def error_404
    render file: "#{Rails.root}/public/404.html", status: 404, layout: false
  end
end
