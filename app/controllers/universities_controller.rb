class UniversitiesController < ApplicationController
  expose :universities, lambda {
    results = University.by_name(query_by_name(params[:name]))
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
    universities.as_json(only: %i[id name local_committee_id city]) +
      other.as_json(only: %i[id name local_committee_id city])
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
      University.where('unaccent(name) ILIKE unaccent(?)', 'otras - %')
                .where('unaccent(city) ILIKE unaccent(?)', city)
    else
      University.where('lower(name) = ?', 'outra')
    end
  end
end
