class Media::RecordingsController < ApplicationController
  # Webhook from MediaMTX (internal Docker network only) — skip CSRF + auth
  skip_before_action :verify_authenticity_token, only: [:recording_complete]
  protect_from_forgery except: [:recording_complete]

  # Shared secret between mediamtx scripts and Rails
  WEBHOOK_SECRET = ENV.fetch('MEDIAMTX_WEBHOOK_SECRET', 'esmx-mediamtx-secret')

  # POST /media/recording_complete
  # Webhook called by MediaMTX runOnRecordSegmentComplete
  # Params: path (stream path), segment (absolute file path in container)
  def recording_complete
    # Verify shared secret
    secret = request.headers['X-Mediamtx-Secret'].to_s
    if secret != WEBHOOK_SECRET
      render json: { error: 'unauthorized' }, status: :unauthorized and return
    end

    # Parse JSON body (wget sends as raw body with Content-Type: application/json)
    body = JSON.parse(request.body.read) rescue {}
    mtx_path     = (params[:path]    || body['path']).to_s.strip
    segment_path = (params[:segment] || body['segment']).to_s.strip

    if mtx_path.blank? || segment_path.blank?
      render json: { error: 'missing path or segment' }, status: :bad_request and return
    end

    RecordingUploadWorker.perform_async(mtx_path, segment_path)

    render json: { status: 'queued', path: mtx_path, segment: File.basename(segment_path) }
  end

  # GET /media/recordings?solution=cusys&stream=test
  # List recordings in media-records bucket, optionally filtered by solution/stream
  def index
    solution = params[:solution].to_s
    stream   = params[:stream].to_s

    prefix = if solution.present? && stream.present?
      "#{solution}/#{stream}/"
    elsif solution.present?
      "#{solution}/"
    else
      ''
    end

    files = MinioRecordsHelper.list(prefix: prefix, max_keys: 500)

    recordings = files.map do |f|
      parts = f[:key].split('/')
      {
        key:          f[:key],
        solution:     parts[0],
        stream:       parts[1],
        filename:     parts[2],
        size_mb:      (f[:size].to_f / 1.megabyte).round(2),
        recorded_at:  f[:last_modified],
        hls_url:      "/hls/playback/#{f[:key]}",
        webrtc_url:   "/webrtc/playback/#{f[:key]}",
        download_url: MinioRecordsHelper.presigned_url(f[:key], expires_in: 3600)
      }
    end

    render json: recordings
  end

  # GET /media/recordings/stream_url?key=cusys/test/20260408_172835.mp4
  # Called by playback.sh in mediamtx container — returns plain-text presigned URL
  def stream_url
    key = params[:key].to_s.strip

    if key.blank?
      render plain: '', status: :bad_request and return
    end

    unless MinioRecordsHelper.head(key)
      render plain: '', status: :not_found and return
    end

    url = MinioRecordsHelper.presigned_url(key, expires_in: 7200)
    render plain: url
  end
end
