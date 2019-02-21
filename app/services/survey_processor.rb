require 'http'

class SurveyProcessor
  STATUSES_BROKEN = %i[break_approval realization_broken]

  def self.call(params)
    new(params).call
  end

  attr_reader :params, :status

  def initialize(params)
    @podio_id = params['podio_id']
    @status = false
  end

  def call
    item = fetch_item

    status = fetch_status(item)

    survey_history = SurveyHistory.first_or_create(podio_id: @podio_id)

    collector = Survey.find_by(status: status).collector

    res = send_survey(item, collector) unless already_sent?(survey_history, collector)

    if res
      @status = true if update_surveys(survey_history, res, collector)
    end

    @status
  end

  private

  def already_sent?(survey_history, collector)
    return false unless survey_history.surveys
    survey_history.surveys.has_key?(collector)
  end

  def fetch_item
    RepositoryPodio.get_item(@podio_id)
  end

  def fetch_status(item)
    status_broken = nil

    field = item.fields.select { |f| f['external_id'] == 'status-expa' }.first
    status = field['values'][0]['value']['text'].downcase.to_sym

    field = item.fields.select { |f| f['external_id'] == 'status-da-quebra' }.first
    status_index = field['values'][0]['value']['id'] if field
    status_broken = SurveyProcessor::STATUSES_BROKEN[status_index - 1] if status_index

    return status if status.in?(%i[approved realized finished]) && status_broken.nil?
    status_broken
  end

  def receiver_name(item)
    field = item.fields.select { |f| f['external_id'] == 'nome-do-ep' }.first
    field['values'][0]['value']['title']
  end

  def receiver_email(item)
    field = item.fields.select { |f| f['external_id'] == 'email' }.first
    field['values'][0]['value']
  end

  def send_survey(item, collector)
    HTTP.basic_auth(user: ENV['BINDS_USERNAME'] , pass: ENV['BINDS_PASSWORD'])
    HTTP.post('https://app.binds.co/api/seeds',
      json: { collector: collector,
              from: { name: receiver_name(item), email: receiver_email(item)} }
    )
  end

  def update_surveys(survey_history, res, collector)
    return false unless res.code == 201

    if survey_history.surveys?
      survey_history.surveys[collector] = { "created_at" => Time.now }
    else
      survey_history.surveys = { collector => { 'created_at' => Time.now } }
    end
    survey_history.save
  end
end
