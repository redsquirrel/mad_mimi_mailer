require "rubygems"
require "test/unit"
require "mocha"

require "mad_mimi_mailer"

MadMimiMailer.api_settings = {
  :username => "testy@mctestin.com",
  :api_key => "w00tb4r"
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
end

class TestMadMimiMailer < Test::Unit::TestCase

  def setup
    ActionMailer::Base.deliveries.clear
  end

  def test_custom_promotion
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
      'username' => "testy@mctestin.com",
      'api_key' =>  "w00tb4r",
      'promotion_name' => "hello",
      'recipients' =>     "tyler@obtiva.com",
      'subject' =>        "welcome to mad mimi",
      'bcc' =>            "Gregg Pollack <gregg@example.com>, David Clymer <david@example>",
      'from' =>           "dave@obtiva.com",
      'body' =>           "--- \n:message: welcome to mad mimi\n",
      'hidden' =>         nil
    )
    response = Net::HTTPSuccess.new("1.2", '200', 'OK')
    response.stubs(:body).returns("123435")
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(response)

    MadMimiMailer.deliver_mimi_hola("welcome to mad mimi")
  end

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
      'body' =>           "--- \n:message: welcome to mad mimi\n",
      'hidden' =>         nil
    )
    response = Net::HTTPSuccess.new("1.2", '200', 'OK')
    response.stubs(:body).returns("123435")
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(response)

    promotion_attempt_id = MadMimiMailer.deliver_mimi_hello("welcome to mad mimi")
    assert_equal "123435", promotion_attempt_id
  end

  def test_blank_bcc
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
      'username' => "testy@mctestin.com",
      'api_key' =>  "w00tb4r",
      'promotion_name' => "hello_sans_bcc",
      'recipients' =>     "tyler@obtiva.com",
      'bcc' =>            nil,
      'subject' =>        "welcome to mad mimi",
      'from' =>           "dave@obtiva.com",
      'body' =>           "--- \n:message: welcome to mad mimi\n",
      'hidden' =>         nil
    )
    response = Net::HTTPSuccess.new("1.2", '200', 'OK')
    response.stubs(:body).returns("123435")
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(response)

    MadMimiMailer.deliver_mimi_hello_sans_bcc("welcome to mad mimi")
  end

  def test_erb_render
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
      'username' => "testy@mctestin.com",
      'api_key' =>  "w00tb4r",
      'promotion_name' => "w00t",
      'recipients' =>     "tyler@obtiva.com",
      'bcc' =>            nil,
      'subject' =>        "welcome to mad mimi",
      'from' =>           "dave@obtiva.com",
      'raw_html' =>       "hi there, welcome to mad mimi [[peek_image]]",
      'hidden' =>         nil
    )
    response = Net::HTTPSuccess.new("1.2", '200', 'OK')
    response.stubs(:body).returns("123435")
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(response)

    MadMimiMailer.deliver_mimi_hello_erb("welcome to mad mimi")
  end

  def test_multipart_erb_render
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
      'username' => "testy@mctestin.com",
      'api_key' =>  "w00tb4r",
      'promotion_name' => 'w00t',
      'recipients' =>     "sandro@hashrocket.com",
      'bcc' =>            nil,
      'subject' =>        "welcome to mad mimi",
      'from' =>           "stephen@hashrocket.com",
      'raw_html' =>       "hi there, welcome to mad mimi [[peek_image]]",
      'hidden' =>         nil
    )
    response = Net::HTTPSuccess.new("1.2", '200', 'OK')
    response.stubs(:body).returns("123435")
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(response)

    MadMimiMailer.deliver_mimi_multipart_hello_erb("welcome to mad mimi")
  end

  def test_deliveries_contain_tmail_objects_when_use_erb_in_test_mode
    ActionMailer::Base.delivery_method = :test
    MadMimiMailer.deliver_mimi_multipart_hello_erb("welcome to mad mimi")
    ActionMailer::Base.delivery_method = :smtp

    assert ActionMailer::Base.deliveries.all?{|m| m.kind_of?(TMail::Mail)}
  end

  def test_erb_render_fails_without_peek_image
    assert_raise MadMimiMailer::ValidationError do
      MadMimiMailer.deliver_mimi_bye_erb("welcome to mad mimi")
    end
  end

  def test_bad_promotion_name
    mock_request = mock("request")
    mock_request.stubs(:set_form_data)
    response = Net::HTTPNotFound.new('1.2', '404', 'Not found')
    response.stubs(:body).returns("Could not find promotion by that name")
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(response)

    assert_raise(Net::HTTPServerException) do
      MadMimiMailer.deliver_mimi_hello("welcome to mad mimi")
    end
  end

  def test_no_more_audience_space
    mock_request = mock("request")
    mock_request.stubs(:set_form_data)
    response = Net::HTTPPaymentRequired.new('1.2', '402', 'Payment required')
    response.stubs(:body).returns("Please upgrade")
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(response)

    assert_raise(Net::HTTPServerException) do
      MadMimiMailer.deliver_mimi_hello("welcome to mad mimi")
    end
  end

  def test_no_mailer_api_enabled
    mock_request = mock("request")
    mock_request.stubs(:set_form_data)
    response = Net::HTTPUnauthorized.new('1.2', '401', 'Unauthorized')
    response.stubs(:body).returns("Please get an mailer api subscription")
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(response)

    assert_raise(Net::HTTPServerException) do
      MadMimiMailer.deliver_mimi_hello("welcome to mad mimi")
    end
  end

  def test_assert_mail_sent
    ActionMailer::Base.delivery_method = :test
    MadMimiMailer.deliver_mimi_hello("welcome to mad mimi")
    ActionMailer::Base.delivery_method = :smtp

    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal "MadMimiMailer", ActionMailer::Base.deliveries.last.class.name
  end
end
