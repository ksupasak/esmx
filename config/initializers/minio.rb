require 'aws-sdk-s3'

_s3_opts = {
  endpoint:         ENV.fetch('MINIO_ENDPOINT', 'http://minio:9000'),
  access_key_id:     ENV.fetch('MINIO_ROOT_USER', 'minioadmin'),
  secret_access_key: ENV.fetch('MINIO_ROOT_PASSWORD', 'minadadmin'),
  region:            ENV.fetch('MINIO_REGION', 'us-east-1'),
  force_path_style:  true
}

# General file storage bucket (esmx-files)
MINIO_CLIENT  = Aws::S3::Client.new(_s3_opts)
MINIO_BUCKET  = ENV.fetch('MINIO_BUCKET', 'esmx-files')

# Dedicated video recordings bucket (media-records)
MINIO_RECORDS_CLIENT = Aws::S3::Client.new(_s3_opts)
MINIO_RECORDS_BUCKET = ENV.fetch('MINIO_RECORDS_BUCKET', 'media-records')

MINIO_RESOURCE = Aws::S3::Resource.new(client: MINIO_CLIENT)
