class ImpactBrazil
  def self.call(params)
    new(params).call
  end

  attr_reader :exchange_participant_id, :opportunity_id, :application_id, :from

  def initialize(params)
    p params.to_json
    p params['applicationId']
    @exchange_participant_id = params['personId']
    @opportunity_id = params['opportunityId']
    @application_id = params['applicationId']
    @from = DateTime.parse(params['date'])
  end

  def call
    create_impact_brazil_referral
  end

  private

  def create_impact_brazil_referral()
    true if ImpactBrazilReferral.create(ep_expa_id: @exchange_participant_id,
                            application_expa_id: @application_id,
                            opportunity_expa_id: @opportunity_id,
                            application_date: @from)
  end
end
