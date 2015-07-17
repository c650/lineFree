# -*- encoding: utf-8 -*-
# stub: Indirizzo 0.1.7 ruby lib

Gem::Specification.new do |s|
  s.name = "Indirizzo"
  s.version = "0.1.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Dave Worth"]
  s.date = "2012-01-29"
  s.description = "Indirizzo is simply an extraction of the US Street Address parsing code from Geocoder::US"
  s.email = "dave@highgroove.com"
  s.extra_rdoc_files = ["LICENSE.txt", "README.md"]
  s.files = ["LICENSE.txt", "README.md"]
  s.homepage = "http://github.com/daveworth/indirizzo"
  s.licenses = ["LGPL"]
  s.rubygems_version = "2.4.3"
  s.summary = "Indirizzo is simply an extraction of the US Street Address parsing code from Geocoder::US"

  s.installed_by_version = "2.4.3" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<cover_me>, [">= 0"])
      s.add_development_dependency(%q<awesome_print>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<cover_me>, [">= 0"])
      s.add_dependency(%q<awesome_print>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<cover_me>, [">= 0"])
    s.add_dependency(%q<awesome_print>, [">= 0"])
  end
end
