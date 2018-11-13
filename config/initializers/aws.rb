unless ENV['TRAVIS_PULL_REQUEST']
  AWS_REGION = Rails.application.credentials[ENV['COUNTRY'].to_sym][:aws][ENV['ENV'].to_sym][:region]
  AWS_ACCESS_KEY_ID = Rails.application.credentials[ENV['COUNTRY'].to_sym][:aws][:access_key_id]
  AWS_SECRET_ACCESS_KEY = Rails.application.credentials[ENV['COUNTRY'].to_sym][:aws][:secret_access_key]

  Aws.config.update({
    region:      AWS_REGION,
    credentials: Aws::Credentials.new(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
  })

  sqs = Aws::SQS::Client.new(
    region:      AWS_REGION,
    credentials: Aws::Credentials.new(AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY)
  )

  # Sign Up Queue
  sqs.create_queue({queue_name: 'databazi_sign_up_queue'})
  sqs.create_queue({queue_name: 'databazi_podio_queue_new'})
end
