# -*- encoding: utf-8 -*-
 
Gem::Specification.new do |s|
  s.name = %q{mad_mimi_mailer}
  s.version = "0.1.2.2"
 
  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dave Hoover"]
  s.date = %q{2010-05-07}
  s.description = %q{Use Mad Mimi to send beautiful HTML emails using the ActionMailer API.}
  s.email = %q{dave@obtiva.com}
  s.files = ["lib/mad_mimi_mailer.rb", "lib/mad_mimi_mailable.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://developer.madmimi.com/}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{mad_mimi_mailer}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Extending ActionMailer::Base for Mad Mimi integration.}
end