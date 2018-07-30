class ExchangeParticipant < ApplicationRecord
  validates :fullname, presence: true
  validates :cellphone, presence: true
  validates :email, presence: true,
                    uniqueness: true
  validates :birthdate, presence: true

  belongs_to :registerable, polymorphic: true
  belongs_to :local_committee
  belongs_to :university
  belongs_to :college_course

  #def self.encrypted_password(password)
  #  key = ENV['KEY']
  #  crypt = ActiveSupport::MessageEncryptor.new(key)
  #  crypt.encrypt_and_sign(password)
  #end

  #def self.decrypted_password(password)
  #  key = ENV['KEY']
  #  crypt = ActiveSupport::MessageEncryptor.new(key)
  #  crypt.decrypt_and_verify(password)
  #end
end
