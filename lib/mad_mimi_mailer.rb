require "actionmailer"
require "net/http"
require "net/https"

class MadMimiMailer < ActionMailer::Base
  VERSION = '0.0.1'
  SINGLE_SEND_URL = 'https://madmimi.com/mailer'

  @@api_settings = {}
  cattr_accessor :api_settings

  class << self  
        
    def method_missing(method_symbol, *parameters)
      if method_symbol.id2name.match(/^deliver_(mimi_[_a-z]\w*)/)
        deliver_mimi_mail($1, *parameters)
        
      else
        super
      end    
    end
    
    def deliver_mimi_mail(method, *parameters)
      mail = new      
      mail.__send__(method, *parameters)
            
      return unless perform_deliveries

      if delivery_method == :test
        deliveries << mail
      else
        call_api!(mail, method)
      end
    end
      
    def call_api!(mail, method)
      response = post_request do |request|
        request.set_form_data(
          'username' => api_settings[:username],
          'api_key' =>  api_settings[:api_key],
          
          'promotion_name' => method.to_s.sub(/^mimi_/, ''),
          'recipients' =>     serialize(mail.recipients),
          'subject' =>        mail.subject,
          'bcc' =>            mail.bcc.present? ? serialize(mail.bcc) : '',
          'from' =>           mail.from,
          'body' =>           mail.body.to_yaml
        )       
      end
      
      case response
      when Net::HTTPSuccess
        response
      else
        response.error!
      end
    end
    
    def post_request
      url = URI.parse(SINGLE_SEND_URL)
      request = Net::HTTP::Post.new(url.path)
      yield(request)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.start do |http|
        http.request(request)
      end
    end
    
    def serialize(recipients)
      case recipients
      when String
        recipients
      when Array
        recipients.join(", ")
      else
        raise "Please provide a String or an Array for recipients or bcc."
      end
    end
  end
end
