class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # force_ssl :except => [:index,:content]
  # SECURITY: permit_all_parameters removed - use explicit permit() in each controller action

end
