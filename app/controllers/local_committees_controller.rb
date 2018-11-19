class LocalCommitteesController < ApplicationController
  expose :local_committees, -> do
    if params[:university_id]
      university = University.find(params[:university_id])
      LocalCommittee.where(id: university.local_committee.id)
    else
      LocalCommittee.all
    end
  end

  def index
    render json: local_committees.as_json
  end
end
