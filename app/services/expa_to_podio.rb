class ExpaToPodio
  def self.call(params)
    new(params).call
  end

  attr_reader :status, :exchange_participant

  def initialize(params)
    @exchange_participant = ExchangeParticipant.find_by(id: params['exchange_participant_id'])
    @status = true
  end

  def call
    podio_id = nil

    podio_id = send_to_podio

    @exchange_participant.update_attribute(:podio_id, podio_id) if podio_id

    return true if create_tag(podio_id)
  end

  private

  def create_tag(podio_id)
    RepositoryPodio.init
    Podio::Tag.create('item', podio_id, ['retentativa-de-cadastro'])
  end

  def send_to_podio
    podio_id = RepositoryPodio.create_item(ENV["PODIO_APP_#{@exchange_participant.program.to_s.upcase}"], podio_params).item_id

    podio_id
  end

  def podio_params
    podio_params = {
      'data-inscricao' => { 'start' => Time.now.strftime('%Y-%m-%d %H:%M:%S') },
      'title' => @exchange_participant.fullname,
      'email' => [{ 'type' => 'home', 'value' => @exchange_participant.email }],
      'data-de-nascimento' => {
        start: Date.parse(@exchange_participant.birthdate.to_s).strftime('%Y-%m-%d %H:%M:%S')
      },
      'cl-marcado-no-expa-nao-conta-expansao-ainda' => @exchange_participant.local_committee.podio_id
      'status-expa' => map_status(@exchange_participant.status)
    }

    if @exchange_participant.program == :gv
      podio_params['di-ep-id'] = @exchange_participant.expa_id
    else
      podio_params['di-ep-id-2'] = @exchange_participant.expa_id
    end

    podio_params
  end

  def map_status(status)
    mapper = {
      open: 1,
      applied: 2,
      accepted: 3,
      approved_tn_manager: 4,
      approved_ep_manager: 4,
      approved: 4,
      break_approved: 5,
      rejected: 6,
      withdrawn: 6,
      realized: 4,
      approval_broken: 6,
      realization_broken: 5,
      matched: 4,
      completed: 4,
      other_status: 6
    }
    mapper[status]
  end
end
