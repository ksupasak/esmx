module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user, :current_solution_id

    def connect
      self.current_user = find_verified_user
      self.current_solution_id = request.session[:esm]
    end

    private

    def find_verified_user
      if (user_id = request.session[:user])
        if user_id.to_s.length < 10
          User.find_by(id: user_id)
        else
          # Solution-specific user
          nil
        end
      else
        nil
      end
    end
  end
end
