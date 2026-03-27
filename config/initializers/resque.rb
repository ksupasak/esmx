rails_root = Rails.root || File.dirname(__FILE__) + '/../..'
rails_env = Rails.env || 'development'

resque_config = YAML.load(ERB.new(File.read(rails_root.to_s + '/config/resque.yml')).result)
Resque.redis = ENV.fetch('REDIS_URL', resque_config[rails_env])
Resque.redis.namespace = "resque:task"

