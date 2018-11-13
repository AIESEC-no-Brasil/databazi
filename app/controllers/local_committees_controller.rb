class LocalCommitteesController < ApplicationController
  expose :local_committees, -> { LocalCommittee.active }

  def index
    render json: local_committees.as_json
  end
end
