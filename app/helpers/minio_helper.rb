module MinioHelper

  # Upload a file to MinIO
  # key: the object path, e.g. "solution_abc/attachments/photo.jpg"
  # body: file content (IO or String)
  # content_type: MIME type
  def self.upload(key, body, content_type: 'application/octet-stream', metadata: {})
    MINIO_CLIENT.put_object(
      bucket:       MINIO_BUCKET,
      key:          key,
      body:         body,
      content_type: content_type,
      metadata:     metadata
    )
    key
  end

  # Upload from a Rails uploaded file (ActionDispatch::Http::UploadedFile)
  def self.upload_file(uploaded_file, prefix: '')
    key = prefix.present? ? "#{prefix}/#{uploaded_file.original_filename}" : uploaded_file.original_filename
    upload(key, uploaded_file.read, content_type: uploaded_file.content_type)
  end

  # Download file content
  def self.download(key)
    resp = MINIO_CLIENT.get_object(bucket: MINIO_BUCKET, key: key)
    resp.body.read
  end

  # Get object metadata without downloading
  def self.head(key)
    MINIO_CLIENT.head_object(bucket: MINIO_BUCKET, key: key)
  rescue Aws::S3::Errors::NotFound
    nil
  end

  # Generate a presigned URL for direct browser download/upload
  def self.presigned_url(key, expires_in: 3600, method: :get)
    signer = Aws::S3::Presigner.new(client: MINIO_CLIENT)
    case method
    when :get
      signer.presigned_url(:get_object, bucket: MINIO_BUCKET, key: key, expires_in: expires_in)
    when :put
      signer.presigned_url(:put_object, bucket: MINIO_BUCKET, key: key, expires_in: expires_in)
    end
  end

  # Delete an object
  def self.delete(key)
    MINIO_CLIENT.delete_object(bucket: MINIO_BUCKET, key: key)
  end

  # List objects with a prefix (e.g. all files for a solution)
  def self.list(prefix: '', max_keys: 1000)
    resp = MINIO_CLIENT.list_objects_v2(bucket: MINIO_BUCKET, prefix: prefix, max_keys: max_keys)
    resp.contents.map { |obj| { key: obj.key, size: obj.size, last_modified: obj.last_modified } }
  end

  # Build a solution-scoped key
  # e.g. MinioHelper.solution_key("my_solution", "projects/docs", "report.pdf")
  def self.solution_key(solution_name, *parts)
    ["solutions/#{solution_name}", *parts].join('/')
  end

end
