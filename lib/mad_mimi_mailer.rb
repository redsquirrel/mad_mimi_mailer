require "action_mailer"
require "net/http"
require "net/https"

class MadMimiMailer < ActionMailer::Base
  VERSION = '0.0.8'
  SINGLE_SEND_URL = 'https://madmimi.com/mailer'

  @@api_settings = {}
  cattr_accessor :api_settings

  # Custom Mailer attributes

  def promotion(promotion = nil)
    if promotion.nil?
      @promotion
    else
      @promotion = promotion
    end
  end

  def use_erb(use_erb = nil)
    if use_erb.nil?
      @use_erb
    else
      @use_erb = use_erb
    end
  end

  def hidden(hidden = nil)
    if hidden.nil?
      @hidden
    else
      @hidden = hidden
    end
  end

  # Class methods

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

      if mail.use_erb
        mail.create!(method, *parameters)
      end

      return unless perform_deliveries

      if delivery_method == :test
        deliveries << (mail.mail ? mail.mail : mail)
      else
        if (all_recipients = mail.recipients).is_a? Array
          all_recipients.each do |recipient|
            mail.recipients = recipient
            call_api!(mail, method)
          end
        else
          call_api!(mail, method)
        end
      end
    end

    def call_api!(mail, method)
      params = {
        'username' => api_settings[:username],
        'api_key' =>  api_settings[:api_key],
        'promotion_name' => mail.promotion || method.to_s.sub(/^mimi_/, ''),
        'recipients' =>     serialize(mail.recipients),
        'subject' =>        mail.subject,
        'bcc' =>            serialize(mail.bcc),
        'from' =>           mail.from,
        'hidden' =>         serialize(mail.hidden)
      }

      if mail.use_erb
        if mail.parts.any?
          params['raw_plain_text'] = content_for(mail, "text/plain")
          params['raw_html'] = content_for(mail, "text/html") { |html| validate(html.body) }
        else
          validate(mail.body)
          params['raw_html'] = mail.body
        end
      else
        params['body'] = mail.body.to_yaml
      end

      response = post_request do |request|
        request.set_form_data(params)
      end

      case response
      when Net::HTTPSuccess
        response.body
      else
        response.error!
      end
    end

    def content_for(mail, content_type)
      part = mail.parts.detect {|p| p.content_type == content_type }
      if part
        yield(part) if block_given?
        part.body
      end
    end
    
    def validate(content)
      unless content.include?("[[peek_image]]") || content.include?("[[tracking_beacon]]")
        raise ValidationError, "You must include a web beacon in your Mimi email: [[peek_image]]"
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
      when NilClass
        nil
      else
        raise "Please provide a String or an Array for recipients or bcc."
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
