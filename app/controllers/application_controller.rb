class ApplicationController < ActionController::Base
  before_action :basic_auth, if: :development?
  protect_from_forgery with: :exception

  private

  def development?
    Rails.env.development?
  end

  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      username == ENV["BASIC_AUTH_USER"] && password == ENV["BASIC_AUTH_PASSWORD"]
    end
  end
end
