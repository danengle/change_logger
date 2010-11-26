# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{change_logger}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Dan Engle"]
  s.date = %q{2010-11-25}
  s.description = %q{A gem for tracking who and what changes}
  s.email = %q{engle.68 @nospam@ gmail.com}
  s.extra_rdoc_files = ["CHANGELOG", "README", "lib/app/models/change_log.rb", "lib/change_logger.rb", "lib/change_logger/acts_as_change_logger.rb", "lib/change_logger/railtie.rb", "lib/change_logger/whodunnit.rb", "lib/generators/change_logger_generator.rb", "lib/generators/templates/create_change_logs.rb"]
  s.files = ["CHANGELOG", "MIT-LICENSE", "README", "Rakefile", "lib/app/models/change_log.rb", "lib/change_logger.rb", "lib/change_logger/acts_as_change_logger.rb", "lib/change_logger/railtie.rb", "lib/change_logger/whodunnit.rb", "lib/generators/change_logger_generator.rb", "lib/generators/templates/create_change_logs.rb", "Manifest", "change_logger.gemspec"]
  s.homepage = %q{http://github.com/danengle/awesome_tables}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Change_logger", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{change_logger}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A gem for tracking who and what changes}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
