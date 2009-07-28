require "rubygems"
require "test/unit"
require "mocha"

require "mad_mimi_mailer"

MadMimiMailer.api_settings = {
  :username => "testy@mctestin.com",
  :api_key => "w00tb4r"
}    

class MadMimiMailer
  def mimi_hello(greeting)
    subject greeting
    recipients "tyler@obtiva.com"
    from "dave@obtiva.com"
    bcc ["Gregg Pollack <gregg@example.com>", "David Clymer <david@example>"]
    body :message => greeting
  end
end

class TestMadMimiMailer < Test::Unit::TestCase

  def test_happy_path
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
      'username' => "testy@mctestin.com",
      'api_key' =>  "w00tb4r",
      'promotion_name' => "hello",
      'recipients' =>     "tyler@obtiva.com",
      'subject' =>        "welcome to mad mimi",
      'bcc' =>            "Gregg Pollack <gregg@example.com>, David Clymer <david@example>",
      'from' =>           "dave@obtiva.com",
      'body' =>           "--- \n:message: welcome to mad mimi\n"
    )
    response = Net::HTTPSuccess.new("1.2", '200', 'OK')
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(response)    

    MadMimiMailer.deliver_mimi_hello("welcome to mad mimi")
  end

  def test_bad_promotion_name
    mock_request = mock("request")
    mock_request.stubs(:set_form_data)
    response = Net::HTTPNotFound.new('1.2', '404', 'Not found')
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(response)    

    assert_raise(Net::HTTPServerException) do
      MadMimiMailer.deliver_mimi_hello("welcome to mad mimi")
    end
  end

  def test_no_more_audience_space
    mock_request = mock("request")
    mock_request.stubs(:set_form_data)
    response = Net::HTTPPaymentRequired.new('1.2', '402', 'Payment required')
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(response)    

    assert_raise(Net::HTTPServerException) do
      MadMimiMailer.deliver_mimi_hello("welcome to mad mimi")
    end
  end
  
  def test_no_autoresponder_enabled
    mock_request = mock("request")
    mock_request.stubs(:set_form_data)
    response = Net::HTTPUnauthorized.new('1.2', '401', 'Unauthorized')
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(response)    

    assert_raise(Net::HTTPServerException) do
      MadMimiMailer.deliver_mimi_hello("welcome to mad mimi")
    end
  end
end
