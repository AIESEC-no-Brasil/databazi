namespace :podio_sync do
  desc "Sync databazi application status to Podio"
  task application_status: :environment do
    Podio.setup(
      api_key: ENV['PODIO_API_KEY'],
      api_secret: ENV['PODIO_API_SECRET']
    )
    Podio.client.authenticate_with_credentials(
      ENV['PODIO_USERNAME'],
      ENV['PODIO_PASSWORD']
    )
    SyncPodioApplicationStatus.call
  end
end
