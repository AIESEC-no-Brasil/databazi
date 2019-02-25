class LocalCommitteesController < ApplicationController
  expose :local_committees, -> do
    if params[:university_id]
      university = University.find(params[:university_id])
      fetch_local_committees.active.where(id: university.local_committee.id)
    else
      fetch_local_committees.active
    end
  end

  def index
    render json: local_committees.as_json
  end

  private

  def fetch_local_committees
    if ENV['COUNTRY'] == 'bra'
      LocalCommittee.brazilian
    else
      LocalCommittee.argentinean
    end
  end

end
