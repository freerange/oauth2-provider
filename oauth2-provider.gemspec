# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{oauth2-provider}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tom Ward"]
  s.date = %q{2010-11-23}
  s.email = %q{tom@popdog.net}
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    ".gitignore",
     "Gemfile",
     "Gemfile.lock",
     "README",
     "Rakefile",
     "lib/oauth2-provider.rb",
     "lib/oauth2/provider.rb",
     "lib/oauth2/provider/access_token.rb",
     "lib/oauth2/provider/access_tokens_controller.rb",
     "lib/oauth2/provider/authorization_code.rb",
     "lib/oauth2/provider/authorization_codes_support.rb",
     "lib/oauth2/provider/client.rb",
     "lib/oauth2/provider/controller_authentication.rb",
     "lib/oauth2/provider/railtie.rb",
     "lib/oauth2/provider/random.rb",
     "lib/oauth2/provider/token_expiry.rb",
     "lib/oauth2/provider/token_scope.rb",
     "oauth2-provider.gemspec",
     "spec/controllers/access_tokens_controller_spec.rb",
     "spec/controllers/authorization_codes_support_spec.rb",
     "spec/controllers/controller_authentication_spec.rb",
     "spec/database.yml",
     "spec/models/access_token_spec.rb",
     "spec/models/authorization_code_spec.rb",
     "spec/models/client_spec.rb",
     "spec/schema.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://tomafro.net}
  s.rdoc_options = ["--main", "README"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{OAuth2 Provider, extracted from api.hashblue.com}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, ["~> 3.0.1"])
      s.add_runtime_dependency(%q<addressable>, ["~> 2.2"])
      s.add_development_dependency(%q<rspec-rails>, ["~> 2.1.0"])
      s.add_development_dependency(%q<rake>, ["~> 0.8.7"])
      s.add_development_dependency(%q<sqlite3-ruby>, ["~> 1.3.1"])
      s.add_development_dependency(%q<timecop>, ["~> 0.3.4"])
      s.add_development_dependency(%q<yajl-ruby>, ["~> 0.7.5"])
    else
      s.add_dependency(%q<rails>, ["~> 3.0.1"])
      s.add_dependency(%q<addressable>, ["~> 2.2"])
      s.add_dependency(%q<rspec-rails>, ["~> 2.1.0"])
      s.add_dependency(%q<rake>, ["~> 0.8.7"])
      s.add_dependency(%q<sqlite3-ruby>, ["~> 1.3.1"])
      s.add_dependency(%q<timecop>, ["~> 0.3.4"])
      s.add_dependency(%q<yajl-ruby>, ["~> 0.7.5"])
    end
  else
    s.add_dependency(%q<rails>, ["~> 3.0.1"])
    s.add_dependency(%q<addressable>, ["~> 2.2"])
    s.add_dependency(%q<rspec-rails>, ["~> 2.1.0"])
    s.add_dependency(%q<rake>, ["~> 0.8.7"])
    s.add_dependency(%q<sqlite3-ruby>, ["~> 1.3.1"])
    s.add_dependency(%q<timecop>, ["~> 0.3.4"])
    s.add_dependency(%q<yajl-ruby>, ["~> 0.7.5"])
  end
end
