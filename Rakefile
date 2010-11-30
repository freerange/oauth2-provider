require "rubygems"
require "bundler"

Bundler.setup :development

require "rspec/core/rake_task"
require "rake/gempackagetask"
require "rake/rdoctask"
require "rake/testtask"

task :default => :spec

# This builds the actual gem. For details of what all these options
# mean, and other ones you can add, check the documentation here:
#
#   http://rubygems.org/read/chapter/20
#
path = File.expand_path("..", __FILE__)

spec = Dir.chdir(path) do
  Gem::Specification.new do |s|

    # Change these as appropriate
    s.name              = "oauth2-provider"
    s.version           = "0.0.2"
    s.summary           = "OAuth2 Provider, extracted from api.hashblue.com"
    s.author            = "Tom Ward"
    s.email             = "tom@popdog.net"
    s.homepage          = "http://tomafro.net"

    s.has_rdoc          = true
    s.extra_rdoc_files  = %w(README)
    s.rdoc_options      = %w(--main README)

    # Add any extra files to include in the gem
    s.files             = `cd #{path} && git ls-files`.split("\n").sort

    # You need to put your code in a directory which can then be added to
    # the $LOAD_PATH by rubygems. Typically this is lib, but you don't seem
    # to have that directory. You'll need to set the line below to whatever
    # directory your code is in. Rubygems is going to assume lib if you leave
    # this blank.
    #
    s.require_paths = ["lib"]

    # Main dependencies
    s.add_dependency 'rails', '~>3.0.1'
    s.add_dependency 'addressable', '~>2.2'

    # Development only dependencies
    s.add_development_dependency 'rspec-rails', '~>2.1.0'
    s.add_development_dependency 'rake', '~>0.8.7'
    s.add_development_dependency 'sqlite3-ruby', '~>1.3.1'
    s.add_development_dependency 'timecop', '~>0.3.4'
    s.add_development_dependency 'yajl-ruby', '~>0.7.5'
    s.add_development_dependency 'mongoid', '2.0.0.beta.20'
    s.add_development_dependency 'bson_ext'
  end
end

# Stolen from jeweler
def prettyify_array(gemspec_ruby, array_name)
  gemspec_ruby.gsub(/s\.#{array_name.to_s} = \[.+?\]/) do |match|
    leadin, files = match[0..-2].split("[")
    leadin + "[\n    #{files.split(",").join(",\n    ")}\n  ]"
  end
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["#{path}/test/**/*test.rb"]
  t.verbose = true
end

# This task actually builds the gem. We also regenerate a static
# .gemspec file, which is useful if something (i.e. GitHub) will
# be automatically building a gem for this project. If you're not
# using GitHub, edit as appropriate.
#
# To publish your gem online, install the 'gemcutter' gem; Read more
# about that here: http://gemcutter.org/pages/gem_docs
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Generate gemspec"
task :gemspec do
  output = spec.to_ruby
  output = prettyify_array(output, :files)
  output = prettyify_array(output, :test_files)
  output = prettyify_array(output, :extra_rdoc_files)

  file = File.expand_path("../#{spec.name}.gemspec", __FILE__)
  File.open(file, "w") {|f| f << output }
end

task :package => :gemspec

# Generate documentation
Rake::RDocTask.new do |rd|
  rd.main = "README"
  rd.rdoc_files.include("README", "lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

desc 'Clear out RDoc and generated packages'
task :clean => [:clobber_rdoc, :clobber_package] do
  rm_f "#{spec.name}.gemspec"
end

desc "Run specs"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "-f n -c"
  t.pattern = "spec/**/*_spec.rb"
end

desc 'Tag the repository in git with gem version number'
task :tag do
  if `git diff --cached`.empty? && `git diff`.empty?
    Rake::Task["package"].invoke

    if `git tag`.split("\n").include?("v#{spec.version}")
      raise "Version #{spec.version} has already been released"
    end
    `git add #{File.expand_path("../#{spec.name}.gemspec", __FILE__)}`
    `git commit -m "Released version #{spec.version}"`
    `git tag v#{spec.version}`
    `git push --tags`
    `git push`
  else
    raise "Repository contains uncommitted changes; either commit or stash."
  end
end