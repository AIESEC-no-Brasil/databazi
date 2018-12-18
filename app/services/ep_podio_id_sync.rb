require 'pstore'

class EpPodioIdSync
  def self.call(**args)
    new.call(args)
  end

  def initialize
    # Podio.setup(
    #   api_key: ENV['PODIO_API_KEY'],
    #   api_secret: ENV['PODIO_API_SECRET']
    # )
    # Podio.client.authenticate_with_credentials(
    #   ENV['PODIO_USERNAME'],
    #   ENV['PODIO_PASSWORD']
    # )
  end

  def call(**args)
    logger = configure_logger(args)
    storage = args[:storage] || PStore.new('podio_id_sync_default.pstore')
    offset = offset_podio(storage)
    logger.info 'EpPodioIdSync.call'

    ret = Podio::Item.find_by_filter_values(
      podio_app_id(storage),
      {},
      sort_by: 'data-inscricao', sort_desc: false, offset: offset
    )
    File.open('json_fixture.json', 'w') { |file| file.write(ret.to_json) }
    ret.all.each do |item|
      begin
        logger.debug "Keys of fields #{item.fields[0].keys}"
        name = item.fields.select{ |field| field['field_id'] == 133074857 }[0]['values'][0]['value']
        email = item.fields.select{ |field| field['field_id'] == 133074860 }[0]['values'][0]['value']
        podio_id = item.app_item_id
        logger.debug "Name #{name} Email #{email}"
        ep = find_ep(email, storage)
        ep.update_attributes(podio_id: podio_id)
      rescue StandardError => ex
        logger.error ex
      end
    end
    logger.info ret.inspect
    ep_type = podio_ep_type(storage)
    storage.transaction do
      offset += 1
      if (offset + 1) * 20 > ret.count
        case ep_type
        when :ge_offset
          done = :ge_offset_done
        when :gv_offset
          done = :gv_offset_done
        when :gt_offset
          done = :gt_offset_done
        end
        storage[done] = true
      end
      storage[ep_type] = offset
    end
  end

  private

  def find_ep(email, storage)
    case podio_ep_type(storage)
    when :ge_offset
      ep = GeParticipant.find_by(email: email, podio_id: nil)
    when :gv_offset
      ep = GvParticipant.find_by(email: email, podio_id: nil)
    when :gt_offset
      ep = GtParticipant.find_by(email: email, podio_id: nil)
    end
    ep
  end

  def podio_app_id(storage)
    case podio_ep_type(storage)
    when :ge_offset
      '17057629'
    when :gv_offset
      '15290822'
    when :gt_offset
      '17057001'
    end
  end

  def offset_podio(storage)
    offset = 0
    ep_type = podio_ep_type(storage)
    storage.transaction { offset = storage.fetch(ep_type, 0) }
    offset
  end

  def podio_ep_type(storage)
    ep_type = storage.transaction do
      ret = :gt_offset unless storage.fetch(:gt_offset_done, false)
      ret = :gv_offset unless storage.fetch(:gv_offset_done, false)
      ret = :ge_offset unless storage.fetch(:ge_offset_done, false)
      ret
    end
  end

  def configure_logger(args)
    default_logger = Logger.new(STDOUT)
    default_logger.level = Logger::WARN
    logger = args[:logger] || default_logger
  end
end
