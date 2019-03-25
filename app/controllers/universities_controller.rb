class UniversitiesController < ApplicationController
  expose :universities, lambda {
    results = University.by_name(query_by_name(params[:name]))
    # TODO: refactor this piece of code into an scope on its model
    if params[:city]
      results = results.where('unaccent(city) ILIKE unaccent(?)', params[:city])
    end

    if ENV['COUNTRY'] == 'per'
      raise ArgumentError, 'missing program parameter' unless params[:program]
      raise ArgumentError, 'missing department parameter' unless params[:department]

      results = results.joins(:university_local_committees)
        .select('universities.id, name, city, university_local_committees.local_committee_id')
        .where(department: params[:department])
        .where(university_local_committees: { program: params[:program] })

    end

    results.limit(limit_response).order(name: :asc)
  }

  expose :other, -> { other_university(params[:city]) }

  def index
    begin 
      render json: format_response
    rescue => e
      render status:400, json: {
        message: e.message
      }
    end
  end

  private

  def limit_response
    params[:limit] || nil
  end

  def format_response
    return other_university_peru if ENV['COUNTRY'] == 'per'

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

  def other_university_peru
    universities = University.where(department: params[:department])
      .joins(:university_local_committees)
      .select('universities.id, name, city, university_local_committees.local_committee_id')
      .where('unaccent(name) ILIKE unaccent(?)', '%otras%')
      .where(department: params[:department])
      .where(university_local_committees: { program: params[:program] }) if universities.blank?    

    universities.as_json(only: %i[id name local_committee_id city])
  end
end
