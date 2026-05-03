class TopicChannel < ApplicationCable::Channel
  def subscribed
    topic = params[:topic]
    solution = params[:solution] || current_solution_id

    if topic.present? && solution.present?
      # Private channel scoped to the solution
      # Same topic name on different solutions = different streams
      @stream_name = "solution:#{solution}:topic:#{topic}"
      stream_from @stream_name
      transmit({ type: "confirm_subscription", topic: topic, solution: solution })
    else
      reject
    end
  end

  def unsubscribed
    # Cleanup when client unsubscribes
  end

  # Client can send messages to the topic
  def speak(data)
    ActionCable.server.broadcast(@stream_name, {
      sender_id:   current_user&.id || data["sender_id"],
      sender_name: data["sender_name"] || current_user&.try(:name) || "User",
      message:     data["message"],
      type:        data["type"] || "message",
      topic:       params[:topic],
      solution:    params[:solution] || current_solution_id,
      time:        Time.now.utc.iso8601
    })
  end

  # Helper: broadcast to a solution's topic from anywhere in Rails
  # TopicChannel.broadcast_to_solution("my_solution", "alerts", { message: "Hello!" })
  def self.broadcast_to_solution(solution, topic, data)
    ActionCable.server.broadcast("solution:#{solution}:topic:#{topic}", data)
  end
end
