module Utils
  class PasswordGenerator
    CHARS = ('0'..'9').to_a + ('A'..'Z').to_a + ('a'..'z').to_a

    def self.call
      new.call
    end

    def call
      password_generator
    end

    private


    def random_password(length=8)
      CHARS.sort_by { rand }.join[0...length]
    end

    def password_generator
      pattern = /^(?:(?=.*\d)(?=.*[a-z])(?=.*[A-Z]).*)$/

      password = ''

      until password.match?(pattern) do
        password = random_password
      end

      password
    end
  end
end
