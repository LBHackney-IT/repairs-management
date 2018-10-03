Aws.config.update(region: 'eu-west-2',
                  access_key_id: Rails.application.credentials.import_s3_access_key,
                  secret_access_key: Rails.application.credentials.import_s3_secret)
