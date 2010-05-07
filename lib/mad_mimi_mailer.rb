require "action_mailer"
require "net/http"
require "net/https"

require "mad_mimi_mailable"

class MadMimiMailer < ActionMailer::Base
  VERSION = '0.1.0'
  SINGLE_SEND_URL = 'https://madmimi.com/mailer'

  @@api_settings = {}
  cattr_accessor :api_settings
  
  @@default_parameters = {}
  cattr_accessor :default_parameters

  include MadMimiMailable

  class << self
    def method_missing(method_symbol, *parameters)
      if method_symbol.id2name.match(/^deliver_(mimi_[_a-z]\w*)/)
        deliver_mimi_mail($1, *parameters)
      else
        super
      end
    end
  end

  class ValidationError < StandardError; end
end

# Adding the response body to HTTPResponse errors to provide better error messages.
module Net
  class HTTPResponse
    def error!
      message = @code + ' ' + @message.dump + ' ' + body
      raise error_type().new(message, self)
    end
  end
end
