require File.dirname(__FILE__) + '/test_helper'

class VanillaMailer < ActionMailer::Base
  include MadMimiMailable

  self.template_root = File.dirname(__FILE__) + '/templates/'
  
  def hola(greeting)
    subject greeting
    recipients "tyler@obtiva.com"
    from "dave@obtiva.com"
    body :message => greeting    
  end

end

class ChocolateErbMailer < ActionMailer::Base
  include MadMimiMailable
  self.method_prefix = "sugary"
  self.use_erb = true

  self.template_root = File.dirname(__FILE__) + '/templates/'
  
  def sugary_hola(greeting)
    subject greeting
    recipients "tyler@obtiva.com"
    from "dave@obtiva.com"
    body :message => greeting    
  end
  
  def sugary_skip_hola(greeting)
    subject greeting
    recipients "tyler@obtiva.com"
    from "dave@obtiva.com"
    body :message => greeting
    skip_placeholders true
  end
end

class MadMimiMailableTest < Test::Unit::TestCase

  def setup
    ActionMailer::Base.deliveries.clear
    @ok_reponse = Net::HTTPSuccess.new("1.2", '200', 'OK')
    @ok_reponse.stubs(:body).returns('123435')
  end

  def test_typical_request
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
      'username' => "testy@mctestin.com",
      'api_key' =>  "w00tb4r",
      'promotion_name' => "hola",
      'recipients' =>     "tyler@obtiva.com",
      'subject' =>        "welcome to mad mimi",
      'bcc' =>            nil,
      'from' =>           "dave@obtiva.com",
      'body' =>           "--- \nmessage: welcome to mad mimi\n",
      'hidden' =>         nil
    )
    VanillaMailer.expects(:post_request).yields(mock_request).returns(@ok_reponse)

    VanillaMailer.deliver_hola("welcome to mad mimi")
  end

  def test_erb_request_with_custom_method_prefix
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
      'username' => "testy@mctestin.com",
      'api_key' =>  "w00tb4r",
      'promotion_name' => "hola",
      'recipients' =>     "tyler@obtiva.com",
      'subject' =>        "welcome to mad mimi",
      'bcc' =>            nil,
      'from' =>           "dave@obtiva.com",
      'raw_html' =>       "hi there, welcome to mad mimi [[peek_image]]",
      'raw_plain_text' =>     nil,
      'hidden' =>         nil
    )
    ChocolateErbMailer.expects(:post_request).yields(mock_request).returns(@ok_reponse)

    ChocolateErbMailer.deliver_sugary_hola("welcome to mad mimi")
  end
  
  def test_erb_request_skipping_placeholders
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
      'username' => "testy@mctestin.com",
      'api_key' =>  "w00tb4r",
      'promotion_name' => "skip_hola",
      'recipients' =>     "tyler@obtiva.com",
      'subject' =>        "{welcome to mad mimi}",
      'bcc' =>            nil,
      'from' =>           "dave@obtiva.com",
      'raw_html' =>       "hi there, {welcome} to mad mimi [[peek_image]]",
      'raw_plain_text' =>     nil,
      'hidden' =>         nil,
      'skip_placeholders' => 'true'
    )
    ChocolateErbMailer.expects(:post_request).yields(mock_request).returns(@ok_reponse)

    ChocolateErbMailer.deliver_sugary_skip_hola("{welcome to mad mimi}")
  end

end
