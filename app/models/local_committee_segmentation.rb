class LocalCommitteeSegmentation < ApplicationRecord
	include ActiveModel::Validations

	enum program: %i[gv ge gt]

	validates :origin_local_committee_id, presence: true
	validates :destination_local_committee_id, presence: true
	validates :program, presence: true

end
