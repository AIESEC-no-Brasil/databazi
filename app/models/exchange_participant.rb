class ExchangeParticipant < ApplicationRecord
  include ActiveModel::Validations
  validates_with YouthValidator

  before_save :encrypted_password

  validates :fullname, presence: true
  validates :cellphone, presence: true
  validates :email, presence: true,
                    uniqueness: true
  validates :birthdate, presence: true
  validates :password, presence: true

  has_many :expa_applications, class_name: 'Expa::Application'

  belongs_to :registerable, polymorphic: true
  belongs_to :campaign, optional: true
  belongs_to :local_committee
  # TODO: assert optional association with shoulda-matchers when
  # new version is available
  belongs_to :university, optional: true
  belongs_to :college_course, optional: true

  accepts_nested_attributes_for :campaign


  enum scholarity: %i[highschool incomplete_graduation graduating
                      post_graduated almost_graduated graduated other]

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
    status_order = ['break_approved', 'rejected', 'open', 'applied', 'accepted', 'approved']
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

  private

  def encrypted_password
    self.password = password_encryptor.encrypt_and_sign(password)
  end

  def password_encryptor
    key = ActiveSupport::KeyGenerator.new('password')
                                     .generate_key(ENV['SALT'], 32)
    ActiveSupport::MessageEncryptor.new(key)
  end
end
