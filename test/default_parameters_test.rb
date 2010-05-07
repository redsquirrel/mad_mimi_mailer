require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class DefaultParametersTest < Test::Unit::TestCase
  def setup
    ActionMailer::Base.deliveries.clear
    @ok_reponse = Net::HTTPSuccess.new("1.2", '200', 'OK')
    @ok_reponse.stubs(:body).returns('123435')
  end
  
  def test_notifier_uses_default_from
    create_mailer_with_default_parameter(:from, 'default_from@example.com')
    
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(has_entry('from' => 'default_from@example.com'))
    @mailer_class.expects(:post_request).yields(mock_request).returns(@ok_reponse)

    @mailer_class.deliver_mimi_default_param
  end
  
  def test_notifier_uses_specified_from_instead_of_default
    create_mailer_with_default_parameter(:from, 'default_from@example.com')
    @mailer_class.class_eval do
      def mimi_specified_param
        from 'specified@example.com'
      end
    end
    
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(has_entry('from' => 'specified@example.com'))
    @mailer_class.expects(:post_request).yields(mock_request).returns(@ok_reponse)

    @mailer_class.deliver_mimi_specified_param
  end
  
  def test_notifier_uses_default_bcc
    create_mailer_with_default_parameter(:bcc, 'default_from@example.com')
    
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(has_entry('bcc' => 'default_from@example.com'))
    @mailer_class.expects(:post_request).yields(mock_request).returns(@ok_reponse)

    @mailer_class.deliver_mimi_default_param
  end
  
  def test_notifier_uses_specified_bcc_instead_of_default
    create_mailer_with_default_parameter(:bcc, 'specified@example.com')
    @mailer_class.class_eval do
      def mimi_specified_param
        bcc 'specified@example.com'
      end
    end
    
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(has_entry('bcc' => 'specified@example.com'))
    @mailer_class.expects(:post_request).yields(mock_request).returns(@ok_reponse)

    @mailer_class.deliver_mimi_specified_param
  end
  
  def test_notifier_uses_default_body
    body_hash = {'host' => 'default.host.com'}
    create_mailer_with_default_parameter(:body, body_hash)
    
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(has_entry('body' => body_hash.to_yaml))
    @mailer_class.expects(:post_request).yields(mock_request).returns(@ok_reponse)

    @mailer_class.deliver_mimi_default_param
  end
  
  def test_notifier_uses_specified_body_instead_of_default
    body_hash = {'host' => 'default.host.com'}
    expected_body_hash = {'host' => 'specified.host.com'}
    create_mailer_with_default_parameter(:body, body_hash)
    @mailer_class.class_eval do
      def mimi_specified_param
        body :host => 'specified.host.com'
      end
    end
    
    mock_request = mock("request")
    mock_request.expects(:set_form_data).with(has_entry('body' => expected_body_hash.to_yaml))
    @mailer_class.expects(:post_request).yields(mock_request).returns(@ok_reponse)

    @mailer_class.deliver_mimi_specified_param
  end
  
  private
  
  def create_mailer_with_default_parameter(param_key, param_value)
    MadMimiMailer.default_parameters = {param_key => param_value}
    
    @mailer_class = Class.new(MadMimiMailer) do
      def mimi_default_param
      end
    end
  end
end
