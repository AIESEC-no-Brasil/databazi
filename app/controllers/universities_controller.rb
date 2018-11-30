class UniversitiesController < ApplicationController
  expose :universities, -> do
    results = University.by_name(query_by_name(params[:name]))
    results = results.where(city: params[:city]) if params[:city]
    results.limit(limit_response)
           .order(name: :asc)
  end

  def index
    render json: format_response
  end

  private

  def limit_response
    params[:limit] || nil
  end

  def format_response
    universities.as_json(only: %i[id name local_committee_id]) +
      other_university.as_json(only: %i[id name local_committee_id])
  end

  def diacritic_trim(param)
    I18n.transliterate(param)
  end

  def query_by_name(param)
    return '' unless param

    diacritic_trim(param)
  end

  def other_university
    University.where('lower(name) = ?', 'outra')
  end
end
