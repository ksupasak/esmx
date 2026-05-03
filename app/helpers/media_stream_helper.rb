module MediaStreamHelper

  MEDIAMTX_API = ENV.fetch('MEDIAMTX_API_URL', 'http://mediamtx:9997')

  # Build a solution-scoped stream path
  # e.g. "solution_abc/camera_1"
  def self.stream_path(solution_name, stream_name)
    "#{solution_name}/#{stream_name}"
  end

  # --- Playback URLs (for browsers/players) ---

  # HLS playback URL (widest browser support)
  def self.hls_url(solution_name, stream_name, host: nil)
    host ||= ENV.fetch('MEDIAMTX_HLS_HOST', 'localhost:8888')
    path = stream_path(solution_name, stream_name)
    "http://#{host}/#{path}/index.m3u8"
  end

  # WebRTC playback URL (lowest latency)
  def self.webrtc_url(solution_name, stream_name, host: nil)
    host ||= ENV.fetch('MEDIAMTX_WEBRTC_HOST', 'localhost:8889')
    path = stream_path(solution_name, stream_name)
    "http://#{host}/#{path}/whep"
  end

  # RTSP URL (for VLC, ffmpeg, etc.)
  def self.rtsp_url(solution_name, stream_name, host: nil)
    host ||= ENV.fetch('MEDIAMTX_RTSP_HOST', 'localhost:8554')
    path = stream_path(solution_name, stream_name)
    "rtsp://#{host}/#{path}"
  end

  # RTMP publish URL (for OBS, ffmpeg push)
  def self.rtmp_publish_url(solution_name, stream_name, host: nil)
    host ||= ENV.fetch('MEDIAMTX_RTMP_HOST', 'localhost:1935')
    path = stream_path(solution_name, stream_name)
    "rtmp://#{host}/#{path}"
  end

  # --- API calls to MediaMTX ---

  # List all active streams
  def self.list_streams
    uri = URI("#{MEDIAMTX_API}/v3/paths/list")
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  rescue StandardError => e
    { 'error' => e.message }
  end

  # Get info about a specific stream
  def self.stream_info(solution_name, stream_name)
    path = stream_path(solution_name, stream_name)
    uri = URI("#{MEDIAMTX_API}/v3/paths/get/#{path}")
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  rescue StandardError => e
    { 'error' => e.message }
  end

  # Kick/close a specific stream
  def self.kick_stream(solution_name, stream_name)
    path = stream_path(solution_name, stream_name)
    uri = URI("#{MEDIAMTX_API}/v3/paths/kick/#{path}")
    req = Net::HTTP::Post.new(uri)
    Net::HTTP.start(uri.hostname, uri.port) { |http| http.request(req) }
  rescue StandardError => e
    { 'error' => e.message }
  end

  # List streams for a specific solution
  def self.solution_streams(solution_name)
    all = list_streams
    return all if all['error']
    items = all['items'] || []
    items.select { |s| s['name'].to_s.start_with?("#{solution_name}/") }
  end

end
