class UniversitiesController < ApplicationController
  expose :universities, lambda {
    results = University.left_outer_joins(:local_committee)
                        .select('universities.id, universities.name, local_committee_id, city, local_committees.whatsapp_link')
                        .by_name(query_by_name(params[:name]))
    # TODO: refactor this piece of code into an scope on its model
    if params[:city]
      results = results.where('unaccent(city) ILIKE unaccent(?)', params[:city])
    end
    results.limit(limit_response)
           .order(name: :asc)
  }

  expose :other, -> { other_university(params[:city]) }

  def index
    render json: format_response
  end

  private

  def limit_response
    params[:limit] || nil
  end

  def format_response
    universities.as_json +
      other.as_json
  end

  def diacritic_trim(param)
    I18n.transliterate(param)
  end

  def query_by_name(param)
    return '' unless param

    diacritic_trim(param)
  end

  def other_university(city)
    if ENV['COUNTRY'] == 'arg'
      University.left_outer_joins(:local_committee)
                .select('universities.id, universities.name, local_committee_id, city, local_committees.whatsapp_link')
                .where('unaccent(universities.name) ILIKE unaccent(?)', 'otras - %')
                .where('unaccent(city) ILIKE unaccent(?)', city)
    else
      University.where('lower(universities.name) = ?', 'outra')
    end
  end
end
