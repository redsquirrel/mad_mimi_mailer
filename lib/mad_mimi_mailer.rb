require "action_mailer"
require "net/http"
require "net/https"

require "mad_mimi_mailable"

class MadMimiMailer < ActionMailer::Base
  VERSION = '0.1.2'

  @@api_settings = {}
  cattr_accessor :api_settings
  
  @@default_parameters = {}
  cattr_accessor :default_parameters

  include MadMimiMailable
  self.method_prefix = "mimi"

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
