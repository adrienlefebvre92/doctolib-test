source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.5"

# Rails core & DB
gem "bootsnap", ">= 1.1.0", require: false
gem "puma", "~> 3.11"
gem "rails", "~> 5.2.3"
gem "sqlite3"

group :development, :test do
  gem "byebug"
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "rubocop"
  gem "rubocop-rails"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
end
