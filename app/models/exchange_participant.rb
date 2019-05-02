class ExchangeParticipant < ApplicationRecord
  include ActiveModel::Validations
  before_create :encrypted_password
  before_save :check_segmentation if ENV['COUNTRY'] == 'arg'

  ARGENTINEAN_SCHOLARITY = %i[incomplete_highschool highschool graduating graduated post_graduating post_graduated]
  BRAZILIAN_SCHOLARITY = %i[highschool incomplete_graduation graduating post_graduated almost_graduated graduated other]

  ARGENTINEAN_REFERRAL_TYPE = { none: 0, friend: 1, friend_facebook: 2, friend_instastories: 3,
                                friend_social_network: 4, google: 5, facebook_group: 6, facebook_ad: 7,
                                instagram_ad: 8, university_presentation: 9, university_mail: 10,
                                university_workshop: 11, university_website: 12, event_or_fair: 13,
                                partner_organization: 14, spanglish_event: 15, potenciate_ad: 16, influencer: 17 }

  PERUVIAN_REFERRAL_TYPE = { none: 0, facebook: 1, instagram: 2, friend_or_family: 3, university_event: 4, university_advertising: 5, other: 6 }

  validates_with YouthValidator, on: :create
  validates_with ScholarityValidator, on: :create


  validates :fullname, presence: true, if: :ogx?
  validates :cellphone, presence: true, if: :ogx?
  validates :email, presence: true,
                    uniqueness: true, if: :ogx?
  validates :birthdate, presence: true, if: :ogx?
  validates :password, presence: true, if: :ogx?

  has_many :expa_applications, class_name: 'Expa::Application'

  belongs_to :registerable, polymorphic: true, optional: true
  belongs_to :campaign, optional: true
  belongs_to :local_committee, optional: true
  belongs_to :university, optional: true
  belongs_to :college_course, optional: true

  accepts_nested_attributes_for :campaign

  enum exchange_type: { ogx: 0, icx: 1 }

  enum status: { open: 1, applied: 2, accepted: 3, approved_tn_manager: 4, approved_ep_manager: 5, approved: 6,
    break_approved: 7, rejected: 8, withdrawn: 9,
    realized: 100, approval_broken: 101, realization_broken: 102, matched: 103,
    completed: 104, finished: 105, other_status: 999 }

  def scholarity_sym(scholarity)
    ENV['COUNTRY'] == 'bra' ? brazilian_scholarity(scholarity) : argentinean_scholarity(scholarity)
  end

  def brazilian_scholarity(scholarity)
    ExchangeParticipant::BRAZILIAN_SCHOLARITY[scholarity]
  end

  def argentinean_scholarity(scholarity)
    ExchangeParticipant::ARGENTINEAN_SCHOLARITY[scholarity]
  end

  def scholarity_length
    if ENV['COUNTRY'] == 'bra'
      brazilian_scholarity_length
    else
      argentinean_scholarity_length
    end
  end

  def brazilian_scholarity_length
    ExchangeParticipant::BRAZILIAN_SCHOLARITY.length
  end

  def argentinean_scholarity_length
    ExchangeParticipant::ARGENTINEAN_SCHOLARITY.length
  end

  def referall_type_sym
    ENV['COUNTRY'] == 'arg' ? argentinean_referral_type(referral_type) : peruvian_referral_type(referral_type)
  end

  def argentinean_referral_type(referral_type)
    ExchangeParticipant::ARGENTINEAN_REFERRAL_TYPE[referral_type]
  end

  def peruvian_referral_type(referral_type)
    ExchangeParticipant::PERUVIAN_REFERRAL_TYPE[referral_type]
  end

  def referral_type_length
    if ENV['COUNTRY'] == 'arg'
      argentinean_referral_type_length
    else
      peruvian_referral_type_length
    end
  end

  def argentinean_referral_type_length
    ExchangeParticipant::ARGENTINEAN_REFERRAL_TYPE.length
  end

  def peruvian_referral_type_length
    ExchangeParticipant::PERUVIAN_REFERRAL_TYPE.length
  end

  def decrypted_password
    return password if password_changed?

    password_encryptor.decrypt_and_verify(password)
  end

  def first_name
    fullname.split(' ').first
  end

  def last_name
    fullname.split(' ').drop(1).join(' ')
  end

  def as_sqs
    { exchange_participant_id: id }
  end

  def most_actual_application(updated_application)
    status_order = %w[
      break_approved
      rejected
      withdrawn
      approval_broken
      realization_broken
      realized
      completed
      open
      matched
      applied
      accepted
      approved_tn_manager
      approved_ep_manager
      approved
    ]
    applications = expa_applications.map do |application|
      updated_application.id == application.id ? updated_application : application
    end
    most_actual = updated_application
    applications.each do |application|
      next if application.rejected?

      if most_actual.rejected?
        most_actual = application
        next
      end

      if status_order.find_index(application.status) > status_order.find_index(most_actual.status)
        most_actual = application
        next
      end
      if application.status == most_actual.status &&
         application.updated_at_expa < most_actual.updated_at_expa
        most_actual = application
      end
    end

    most_actual
  end

  def self.brazilian_scholarity(symbol)
    scholarity = {
      highschool: "Ensino Médio Completo",
      incomplete_graduation: "Graduação Incompleta",
      graduating: "Estudante de Graduação",
      post_graduated: "Mestrado ou Pós",
      almost_graduated: "Graduado em até 1,5 anos",
      graduated: "Graduado há mais de 2 anos",
      other: "Outro"
    }

    scholarity[symbol]
  end

  private

  def encrypted_password
    self.password = password_encryptor.encrypt_and_sign(password)
  end

  def password_encryptor
    key = ActiveSupport::KeyGenerator.new('password')
                                     .generate_key(ENV['SALT'], 32)
    ActiveSupport::MessageEncryptor.new(key)
  end

  def check_segmentation
    programs = { gv: 0, ge: 1, gt: 2 }
    program = self.registerable_type.downcase[0..1].to_sym
    local_committee_segmentation = LocalCommitteeSegmentation.where('origin_local_committee_id = ? and program = ?', 
                                                                      self.local_committee_id, 
                                                                      programs[program]).first

    self.local_committee_id = local_committee_segmentation.destination_local_committee_id if local_committee_segmentation
  end

end
