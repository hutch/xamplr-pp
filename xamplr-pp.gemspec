# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{xamplr-pp}
  s.version = "1.1.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bob Hutchison"]
  s.date = %q{2009-12-11}
  s.email = %q{hutch@recursive.ca}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "Makefile",
     "README.rdoc",
     "Rakefile",
     "VERSION.yml",
     "lapidary-tests/TC_EventTypes.rb",
     "lapidary-tests/TC_Features.rb",
     "lapidary-tests/TC_Input.rb",
     "lapidary-tests/TC_Input000.data",
     "lapidary-tests/TC_Input001.data",
     "lapidary-tests/TC_Misc.rb",
     "lapidary-tests/TC_Namespace.rb",
     "lapidary-tests/TC_Parse.rb",
     "lapidary-tests/TC_Parse000.data",
     "lapidary-tests/TS_xpp.rb",
     "lib/xampl-pp-dtd.rb",
     "lib/xampl-pp-wf.rb",
     "lib/xamplr-pp-18x.rb",
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
     "lib/xamplr-pp/xmlName.defn",
     "lib/xamplr-pp/xpp.rb",
     "lib/xamplr-pp/xppDeluxe.rb",
     "lib/xamplr-pp/xppIter.rb",
     "xamplr-pp.gemspec"
  ]
  s.homepage = %q{http://github.com/hutch/xamplr-pp}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A pure ruby XML pull parser}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
