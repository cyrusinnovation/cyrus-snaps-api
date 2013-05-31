source 'https://rubygems.org'
ruby "1.9.3"

gem "carrierwave",     "~> 0.8.0"
gem "json",            "~> 1.7.5"
gem "sequel",          "~> 3.40.0"
gem "sinatra",         "~> 1.4.2"
gem "sinatra-contrib", "~> 1.4.0"
gem "thin",            "~> 1.5.0"
gem "uuid",            "~> 2.3.6"
gem "validus",         "~> 0.0.1"

gem "simplecov", "~> 0.7.1", :require => false, :group => :test

group :development, :test do
  gem "contest",   "~> 0.1.3"
  gem "flay",      "~> 1.4.3"
  gem "flog",      "~> 2.5.3"
  gem "mocha",     "~> 0.13.0"
  gem "rack-test", "~> 0.6.2"
  gem "rake",      "~> 10.0.2"
  gem "rdoc",      "~> 3.12"
  gem "sqlite3",   "~> 1.3.6"
end

group :production do
  gem "fog", "~> 1.6.0"
  gem "pg",  "~> 0.14.1"
end
