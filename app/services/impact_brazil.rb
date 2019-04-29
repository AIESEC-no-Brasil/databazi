class ImpactBrazil
  def self.call(params)
    new(params).call
  end

  attr_reader :status, :exchange_participant_id, :opportunity_id, :from

  def initialize(params)
    @exchange_participant_id = params['personId']
    @opportunity_id = params['opportunityId']
    @from = DateTime.parse(params['date']).beginning_of_minute.utc

    @status = false
  end

  def call

    expa_applications = RepositoryExpaApi.load_impact_brazil_applications(@exchange_participant_id, @opportunity_id)

    impact_brazil_application = expa_applications.map do |app|
      app if application_in_date_range?(app)
    end

    impact_brazil_application = impact_brazil_application.compact.first

    check_impact_brazil_application(impact_brazil_application)

    @status
  end

  private

  def application_in_date_range?(application)
    application_date = application.applied_at.utc
    @from <= application_date && application_date <= @from + 1.minute
  end

  def check_impact_brazil_application(impact_brazil_application)
    @status = true if create_impact_brazil_referral(impact_brazil_application)
  end

  def create_impact_brazil_referral(impact_brazil_application)
    ImpactBrazilReferral.create(ep_expa_id: @exchange_participant_id,
                            application_expa_id: impact_brazil_application.try(:expa_id),
                            opportunity_expa_id: @opportunity_id,
                            application_date: @from)
  end
end
