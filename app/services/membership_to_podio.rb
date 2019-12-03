class MembershipToPodio
  def self.call(params)
    new(params).call
  end

  attr_reader :membership, :status

  def initialize(params)
    @status = false

    @membership = Membership.find_by(id: params['membership_id'])
  end

  def call
    @status = true if RepositoryPodio.create_item(ENV['PODIO_MEMBERSHIP_APP'], podio_params)
  end

  private

  def podio_params
    {
      'titulo' => @membership.fullname,
      'data-de-nascimento' => {
        start: Date.parse(@membership.birthdate.to_s).strftime('%Y-%m-%d %H:%M:%S')
      },
      'email' => [{ 'type' => 'home', 'value' => @membership.email }],
      'telefone' => [{ 'type' => 'home', 'value' => @membership.cellphone }],
      'cidade' => @membership.city,
      'curso' => @membership.college_course.podio_item_id.to_i,
      'aiesec-mais-proxima' => @membership.local_committee.podio_id,
      'estado' => state_id(@membership.state),
      'cellphone-contactable' => cellphone_contactable_to_podio(@membership.cellphone_contactable)
    }
  end

  def state_id(state)
    {
      ac: 306774391,
      al: 306774380,
      ap: 306774355,
      am: 306774332,
      ba: 306774316,
      ce: 306774285,
      df: 306774262,
      go: 306774221,
      mt: 306774028,
      ms: 306774009,
      mg: 306773976,
      pa: 306773912,
      pb: 306773794,
      pr: 306773760,
      pe: 306773733,
      pi: 306773694,
      rj: 306773655,
      rn: 306773612,
      rs: 306773082,
      rr: 306772658,
      sc: 306772553,
      sp: 306772427,
      se: 306772401,
      to: 306772372
    }[state.downcase.to_sym]
  end

  def cellphone_contactable_to_podio(cellphone_contactable)
    cellphone_contactable ? 1 : 2
  end
end
