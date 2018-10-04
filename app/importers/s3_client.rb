class S3Client
  def s3_object_stream(s3_object_name)
    Aws::S3::Client.new
                   .get_object(bucket: 'hackney-repairs-import', key: s3_object_name)
                   .body
  end
end
