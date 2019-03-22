namespace :update_podio_id do
  desc "Update podio_id"

  task oge: :environment do
    desc "from oGE leads"

    setup_podio
    authenticate_podio

    eps = ExchangeParticipant.where("registerable_type = 'GvParticipant' and exchange_type = 0 and podio_id is null")

    eps.each do |ep|
      item_id = query_podio_by_email(ep.email, ENV['PODIO_APP_GE'])
      if item_id
        puts "#{ep.email} item id is #{item_id}"
        puts "EP updated!" if ep.update_attribute(:podio_id, item_id)
      else
        puts "EP #{ep.email} not found on Podio"
      end
      sleep(8)
    end
  end
end

def authenticate_podio
  Podio.client.authenticate_with_credentials(
    ENV['PODIO_USERNAME'],
    ENV['PODIO_PASSWORD']
  )
end

def setup_podio
  Podio.setup(
    api_key: ENV['PODIO_API_KEY'],
    api_secret: ENV['PODIO_API_SECRET']
  )
end

def query_podio_by_email(email, app_area)
  Podio::Item.find_by_filter_values(
    app_area,
    'email': [email]
  )&.all&.first&.item_id
end
