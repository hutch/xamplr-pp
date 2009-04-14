# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{xamplr-pp}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bob Hutchison"]
  s.date = %q{2009-04-14}
  s.email = %q{hutch@recursive.ca}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "lib/xamplr-pp.rb",
    "lib/xamplr-pp/ANNOUNCE.TXT",
    "lib/xamplr-pp/LICENSE",
    "lib/xamplr-pp/Makefile",
    "lib/xamplr-pp/examples/parse-wf.rb",
    "lib/xamplr-pp/examples/parse.rb",
    "lib/xamplr-pp/license.inc",
    "lib/xamplr-pp/saxdemo.rb",
    "lib/xamplr-pp/saxish.rb",
    "lib/xamplr-pp/saxishHandler.rb",
    "lib/xamplr-pp/toys/chew.rb",
    "lib/xamplr-pp/toys/chewMultibyte.rb",
    "lib/xamplr-pp/toys/dump.rb",
    "lib/xamplr-pp/xampl-pp-dtd.rb",
    "lib/xamplr-pp/xampl-pp-wf.rb",
    "lib/xamplr-pp/xampl-pp.rb",
    "lib/xamplr-pp/xmlName.defn",
    "lib/xamplr-pp/xpp.rb",
    "lib/xamplr-pp/xppDeluxe.rb",
    "lib/xamplr-pp/xppIter.rb",
    "lib/xamplr_pp_gem.rb",
    "test/test_helper.rb",
    "test/xamplr_pp_gem_test.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/hutch/xamplr-pp}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A pure ruby XML pull parser}
  s.test_files = [
    "test/test_helper.rb",
    "test/xamplr_pp_gem_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
