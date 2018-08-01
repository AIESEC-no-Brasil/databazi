class ExchangeParticipant < ApplicationRecord
  before_save :encrypted_password

  validates :fullname, presence: true
  validates :cellphone, presence: true
  validates :email, presence: true,
                    uniqueness: true
  validates :birthdate, presence: true
  validates :password, presence: true

  belongs_to :registerable, polymorphic: true
  belongs_to :local_committee
  belongs_to :university
  belongs_to :college_course

  def decrypted_password
    return self.password if self.password_changed?
    password_encryptor.decrypt_and_verify(self.password)
  end

  private

  def encrypted_password
    self.password = password_encryptor.encrypt_and_sign(self.password)
  end

  def password_encryptor
    salt = Rails.application.credentials.salt
    key = ActiveSupport::KeyGenerator.new('password').generate_key(salt, 32)
    ActiveSupport::MessageEncryptor.new(key)
  end

end
