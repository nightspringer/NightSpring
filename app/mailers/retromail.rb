class Retromail < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers

  default from:       ENV.fetch('SMTP_FROM', 'NightSpring <noreply@nightspring.net>'),
          reply_to:   ENV.fetch('SMTP_REPLY_TO', 'contact@nightspring.net'),
          return_path: ENV.fetch('SMTP_RETURN_PATH', 'contact@nightspring.net'),
          template_path: 'devise/mailer',
          parts_order: ['text/plain', 'text/html']

  layout 'mail'

  def devise_mail(record, action, opts = {})
    initialize_from_record(record)
    mail(headers_for(action, opts)) do |format|
      format.text
      format.html
    end
  end

  def confirmation_instructions(record, token, opts = {})
    @token = token
    devise_mail(record, :confirmation_instructions, opts)
  end
end
