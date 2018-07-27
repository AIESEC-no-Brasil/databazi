class LocalCommitteesController < ApplicationController
  expose :local_committees, -> { LocalCommittee.all }

  def index
    render json: local_committees.as_json
  end
end
