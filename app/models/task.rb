# encoding: UTF-8

class Task
  include Sidekiq::Worker

  sidekiq_options queue: :task, retry: 3

  attr_reader :params

  def initialize(params = {})
    @params = params
  end

  def perform(params)
    # Override in subclasses
  end

  def self.enqueue(params)
    queue = 'default'
    queue = params[:queue] if params[:queue]
    self.set(queue: queue).perform_async(params)
  end
end
