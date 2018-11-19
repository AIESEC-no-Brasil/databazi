class LocalCommitteesController < ApplicationController
  expose :local_committees, -> do
    if params[:university_id]
      university = University.find(params[:university_id])
      LocalCommittee.active.where(id: university.local_committee.id)
    else
      LocalCommittee.active
    end
  end

  def index
    render json: local_committees.as_json
  end
end
