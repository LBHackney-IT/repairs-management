class S3Client
  def s3_object_stream(s3_object_name)
    s3 = Aws::S3::Client.new(
      region: 'eu-west-2',
      access_key_id: Rails.application.credentials.import_s3_access_key,
      secret_access_key: Rails.application.credentials.import_s3_secret)

    s3.get_object(bucket: 'hackney-repairs-import', key: s3_object_name).body
  end
end
