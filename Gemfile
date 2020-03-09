source 'https://rubygems.org'
git_source(:github) { |repo| "git@github.com:#{repo}.git" }

gemspec

gem 'workarea', git: 'https://github.com/workarea-commerce/workarea.git', branch: 'v3.5-stable'
gem 'workarea-oms', git: "https://x-access-token:#{ENV['GITHUB_ACCESS_TOKEN']}@github.com/workarea-commerce/workarea-oms.git"

group :test do
  gem 'simplecov', require: false
end
