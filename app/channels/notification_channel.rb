class NotificationChannel < ApplicationCable::Channel
  def subscribed
    solution = current_solution_id

    if solution.present?
      # Private notification stream per solution
      stream_from "solution:#{solution}:notifications"

      # Also stream user-specific notifications if logged in
      if current_user
        stream_from "solution:#{solution}:user:#{current_user.id}:notifications"
      end
    else
      stream_from "notifications:general"
    end
  end

  def unsubscribed
    # Cleanup when client unsubscribes
  end

  # Helper: broadcast to all users in a solution
  # NotificationChannel.broadcast_to_solution("my_solution", { message: "Hello!" })
  def self.broadcast_to_solution(solution, data)
    ActionCable.server.broadcast("solution:#{solution}:notifications", data)
  end

  # Helper: broadcast to a specific user in a solution
  # NotificationChannel.broadcast_to_user("my_solution", user_id, { message: "Hello!" })
  def self.broadcast_to_user(solution, user_id, data)
    ActionCable.server.broadcast("solution:#{solution}:user:#{user_id}:notifications", data)
  end
end
