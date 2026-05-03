module MinioRecordsHelper

  # Upload a recording segment to media-records bucket
  # key: e.g. "cusys/test/20260408_172835.mp4"
  def self.upload(key, body, metadata: {})
    MINIO_RECORDS_CLIENT.put_object(
      bucket:       MINIO_RECORDS_BUCKET,
      key:          key,
      body:         body,
      content_type: 'video/mp4',
      metadata:     metadata
    )
    key
  end

  def self.head(key)
    MINIO_RECORDS_CLIENT.head_object(bucket: MINIO_RECORDS_BUCKET, key: key)
  rescue Aws::S3::Errors::NotFound
    nil
  end

  def self.list(prefix: '', max_keys: 1000)
    resp = MINIO_RECORDS_CLIENT.list_objects_v2(
      bucket:    MINIO_RECORDS_BUCKET,
      prefix:    prefix,
      max_keys:  max_keys
    )
    resp.contents.map do |obj|
      { key: obj.key, size: obj.size, last_modified: obj.last_modified }
    end
  end

  def self.presigned_url(key, expires_in: 7200)
    signer = Aws::S3::Presigner.new(client: MINIO_RECORDS_CLIENT)
    signer.presigned_url(:get_object, bucket: MINIO_RECORDS_BUCKET, key: key, expires_in: expires_in)
  end

  def self.delete(key)
    MINIO_RECORDS_CLIENT.delete_object(bucket: MINIO_RECORDS_BUCKET, key: key)
  end

end
