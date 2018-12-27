unless ENV['TRAVIS_PULL_REQUEST']
  AWS_REGION = ENV['AWS_REGION']
  AWS_ACCESS_KEY_ID = ENV['AWS_ACCESS_KEY_ID']
  AWS_SECRET_ACCESS_KEY = ENV['AWS_SECRET_ACCESS_KEY']

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
  sqs.create_queue({queue_name: 'databazi_expa_application_sync_queue'})
end
