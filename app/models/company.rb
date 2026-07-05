class Company < ApplicationRecord
  validates :notification_email,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            allow_blank: true
end
