class RecordingUploadWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: 3

  # Called by MediaMTX webhook when a recording segment is complete.
  # Uploads the segment to MinIO media-records bucket keyed as:
  #   {mtx_path}/{filename}  e.g. cusys/test/20260408_172835.mp4
  def perform(mtx_path, segment_path)
    unless File.exist?(segment_path)
      logger.warn "[RecordingUpload] File not found: #{segment_path}"
      return
    end

    filename  = File.basename(segment_path)
    minio_key = "#{mtx_path}/#{filename}"

    logger.info "[RecordingUpload] #{segment_path} → media-records/#{minio_key}"

    File.open(segment_path, 'rb') do |file|
      MinioRecordsHelper.upload(
        minio_key,
        file,
        metadata: {
          'stream-path' => mtx_path,
          'recorded-at' => Time.now.utc.iso8601,
          'filename'    => filename
        }
      )
    end

    logger.info "[RecordingUpload] Upload complete — deleting local #{segment_path}"
    File.delete(segment_path)

  rescue => e
    logger.error "[RecordingUpload] Error: #{e.message}\n#{e.backtrace.first(3).join("\n")}"
    raise
  end
end
