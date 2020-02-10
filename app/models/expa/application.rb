class Expa::Application < ApplicationRecord
  after_save :prep_phase_check

  PREP_STATUS = [:realized, :completed, :finished]
  PREP_BROKEN_STATUS = [:approval_broken, :realization_broken]

  scope :first_approved_at, -> { approveds.order(:approved_at).first }
  scope :approveds, -> { where.not(approved_at: nil).order(:approved_at) }
  scope :synchronized_approveds, -> { approveds.where.not(podio_id: nil) }

  delegate :expa_id, :email, :cellphone, :local_committee_podio_id, to: :exchange_participant, prefix: :exchange_participant, allow_nil: true

  belongs_to :exchange_participant, foreign_key: :exchange_participant_id, optional: true
  belongs_to :host_lc, class_name: 'LocalCommittee', optional: true
  belongs_to :home_lc, class_name: 'LocalCommittee', optional: true
  belongs_to :home_mc, class_name: 'MemberCommittee', optional: true

  validates :product, presence: true
  validates :tnid, presence: true

  enum product: %i[gv ge gt]

  enum status: { open: 1, applied: 2, accepted: 3, approved_tn_manager: 4, approved_ep_manager: 5, approved: 6,
            break_approved: 7, rejected: 8, withdrawn: 9,
            realized: 100, approval_broken: 101, realization_broken: 102, matched: 103,
            completed: 104, finished: 105 }

  def opportunity_link
    "https://aiesec.org/opportunity/#{tnid}"
  end

  def product_upcase
    product.to_s.upcase
  end

  private

  def prep_phase_check
    setup_and_dispatch if pending_initial_sync
    update_status if pending_status_change
  end

  def setup_and_dispatch
    integrator = eval(ENV['COUNTRY_MODULE'] + "::PodioOgxPrepIntegrator")

    update_application_locally if integrator.call(self)
  end

  def update_application_locally
    self.update_attribute(:podio_last_synched_status, self.status)
  end

  def update_status
    integrator = eval(ENV['COUNTRY_MODULE'] + "::PodioOgxStatusUpdate")

    integrator.call(self)
  end

  def pending_initial_sync
    self.status == 'approved' && self.prep_podio_id.blank? && self&.exchange_participant&.exchange_type == 'ogx'
  end

  def pending_status_change
    self.status != self.podio_last_synched_status && self.prep_podio_id
  end
end
