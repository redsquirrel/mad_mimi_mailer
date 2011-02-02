require "rubygems"
require "test/unit"
require "mocha"

require "mad_mimi_mailer"

MadMimiMailer.api_settings = {
    :username => "testy@mctestin.com",
    :api_key  => "w00tb4r"
}

class MadMimiMailer
  self.template_root = File.dirname(__FILE__) + '/templates/'

  def mimi_hola(greeting)
    subject greeting
    recipients "tyler@obtiva.com"
    from "dave@obtiva.com"
    bcc ["Gregg Pollack <gregg@example.com>", "David Clymer <david@example>"]
    promotion "hello"
    body :message => greeting
  end

  def mimi_hello(greeting)
    subject greeting
    recipients "tyler@obtiva.com"
    from "dave@obtiva.com"
    bcc ["Gregg Pollack <gregg@example.com>", "David Clymer <david@example>"]
    body :message => greeting
  end

  def mimi_hello_erb(greeting)
    subject greeting
    recipients "tyler@obtiva.com"
    from "dave@obtiva.com"
    promotion "w00t"
    use_erb true
    body :message => greeting
  end

  def mimi_multipart_hello_erb(greeting)
    subject greeting
    recipients "sandro@hashrocket.com"
    from "stephen@hashrocket.com"
    promotion "w00t"
    use_erb true
    body :message => greeting
  end

  def mimi_bye_erb(greeting)
    subject greeting
    recipients "tyler@obtiva.com"
    from "dave@obtiva.com"
    promotion "w00t"
    use_erb true
    body :message => greeting
  end

  def mimi_hello_sans_bcc(greeting)
    subject greeting
    recipients "tyler@obtiva.com"
    from "dave@obtiva.com"
    body :message => greeting
  end

  def mimi_unconfirmed(greeting)
    subject greeting
    recipients 'egunderson@obtiva.com'
    from 'mimi@obtiva.com'
    promotion 'woot'
    body :message => greeting
    unconfirmed true
  end

  def mimi_supressed(greeting)
    subject greeting
    recipients 'egunderson@obtiva.com'
    from 'mimi@obtiva.com'
    promotion 'woot'
    body :message => greeting
    check_suppressed true
  end

  def normal_non_mimi_email
    subject "Look, I'm normal!"
    recipients "tyler@obtiva.com"
    from "dave@obtiva.com"
    body :message => "something"
  end
end
