require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class MadMimiMailerTest < Test::Unit::TestCase

  def setup
    ActionMailer::Base.deliveries.clear
    @ok_reponse = Net::HTTPSuccess.new("1.2", '200', 'OK')
    @ok_reponse.stubs(:body).returns('123435')
  end

  def test_custom_promotion
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
        'username'       => "testy@mctestin.com",
        'api_key'        => "w00tb4r",
        'promotion_name' => "hello",
        'recipients'     => "tyler@obtiva.com",
        'subject'        => "welcome to mad mimi",
        'bcc'            => "Gregg Pollack <gregg@example.com>, David Clymer <david@example>",
        'from'           => "dave@obtiva.com",
        'body'           => "--- \nmessage: welcome to mad mimi\n",
        'hidden'         => nil
    )
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(@ok_reponse)

    MadMimiMailer.deliver_mimi_hola("welcome to mad mimi")
  end

  def test_happy_path
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
        'username'       => "testy@mctestin.com",
        'api_key'        => "w00tb4r",
        'promotion_name' => "hello",
        'recipients'     => "tyler@obtiva.com",
        'subject'        => "welcome to mad mimi",
        'bcc'            => "Gregg Pollack <gregg@example.com>, David Clymer <david@example>",
        'from'           => "dave@obtiva.com",
        'body'           => "--- \nmessage: welcome to mad mimi\n",
        'hidden'         => nil
    )
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(@ok_reponse)

    promotion_attempt_id = MadMimiMailer.deliver_mimi_hello("welcome to mad mimi")
    assert_equal "123435", promotion_attempt_id
  end

  def test_blank_bcc
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
        'username'       => "testy@mctestin.com",
        'api_key'        => "w00tb4r",
        'promotion_name' => "hello_sans_bcc",
        'recipients'     => "tyler@obtiva.com",
        'bcc'            => nil,
        'subject'        => "welcome to mad mimi",
        'from'           => "dave@obtiva.com",
        'body'           => "--- \nmessage: welcome to mad mimi\n",
        'hidden'         => nil
    )
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(@ok_reponse)

    MadMimiMailer.deliver_mimi_hello_sans_bcc("welcome to mad mimi")
  end

  def test_erb_render
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
        'username'       => "testy@mctestin.com",
        'api_key'        => "w00tb4r",
        'promotion_name' => "w00t",
        'recipients'     => "tyler@obtiva.com",
        'bcc'            => nil,
        'subject'        => "welcome to mad mimi",
        'from'           => "dave@obtiva.com",
        'raw_html'       => "hi there, welcome to mad mimi [[peek_image]]",
        'hidden'         => nil
    )
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(@ok_reponse)

    MadMimiMailer.deliver_mimi_hello_erb("welcome to mad mimi")
  end

  def test_multipart_erb_render
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
        'username'       => "testy@mctestin.com",
        'api_key'        => "w00tb4r",
        'promotion_name' => 'w00t',
        'recipients'     => "sandro@hashrocket.com",
        'bcc'            => nil,
        'subject'        => "welcome to mad mimi",
        'from'           => "stephen@hashrocket.com",
        'raw_html'       => "hi there, welcome to mad mimi [[tracking_beacon]]",
        'raw_plain_text' => "hi there, welcome to mad mimi!",
        'hidden'         => nil
    )
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(@ok_reponse)

    MadMimiMailer.deliver_mimi_multipart_hello_erb("welcome to mad mimi")
  end

  def test_delivers_contain_unconfirmed_param_if_unconfirmed_is_set
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
        'username'       => "testy@mctestin.com",
        'api_key'        => "w00tb4r",
        'body'           => "--- \nmessage: welcome unconfirmed user\n",
        'promotion_name' => "woot",
        'recipients'     => 'egunderson@obtiva.com',
        'bcc'            => nil,
        'subject'        => "welcome unconfirmed user",
        'from'           => "mimi@obtiva.com",
        'hidden'         => nil,
        'unconfirmed'    => '1'
    )
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(@ok_reponse)

    MadMimiMailer.deliver_mimi_unconfirmed("welcome unconfirmed user")
  end

#  check_suppressed true
#    subject greeting
#    recipients 'egunderson@obtiva.com'
#    from 'mimi@obtiva.com'
#    promotion 'woot'
#    body :message => greeting
#    unconfirmed true

  def test_delivers_check_suppressed_param_if_check_suppressed_is_set
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(
        'username'         => "testy@mctestin.com",
        'api_key'          => "w00tb4r",
        'body'             => "--- \nmessage: welcome user\n",
        'promotion_name'   => "woot",
        'recipients'       => 'egunderson@obtiva.com',
        'bcc'              => nil,
        'subject'          => "welcome user",
        'from'             => "mimi@obtiva.com",
        'hidden'           => nil,
        'check_suppressed' => '1'
    )
    MadMimiMailer.expects(:post_request).yields(mock_request).returns(@ok_reponse)

    MadMimiMailer.deliver_mimi_supressed("welcome user")
  end

  def test_deliveries_contain_tmail_objects_when_use_erb_in_test_mode
    ActionMailer::Base.delivery_method = :test
    MadMimiMailer.deliver_mimi_multipart_hello_erb("welcome to mad mimi")
    ActionMailer::Base.delivery_method = :smtp

    assert ActionMailer::Base.deliveries.all? { |m| m.kind_of?(TMail::Mail) }
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

  def test_normal_non_mimi_email
    ActionMailer::Base.delivery_method = :test
    MadMimiMailer.expects(:post_request).never
    MadMimiMailer.deliver_normal_non_mimi_email
  end

  def test_assert_mail_sent
    ActionMailer::Base.delivery_method = :test
    MadMimiMailer.deliver_mimi_hello("welcome to mad mimi")
    ActionMailer::Base.delivery_method = :smtp

    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal "MadMimiMailer", ActionMailer::Base.deliveries.last.class.name
  end
end
