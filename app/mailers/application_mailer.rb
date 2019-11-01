class ApplicationMailer < ActionMailer::Base
  default from: ENV['MAILER_EMAIL']
  layout 'mailer'
end
