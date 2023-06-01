class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # force_ssl :except => [:index,:content]
       ActionController::Parameters.permit_all_parameters = true
  
end
