# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

source 'https://rubygems.org'

gem 'rails', '~> 4.2'
gem 'active_scheduler', '~>0.3.0'
gem 'resque', '~>1.26.0'
gem 'resque-pool', '~>0.6.0'
gem 'resque-scheduler', '~>4.3.0'
gem 'cancan'
gem 'devise'
gem 'dpn-bagit', '~>0.3.0'
gem 'dpn-client', '~>2.0.0', git: 'https://github.com/dpn-admin/dpn-client.git'
gem 'dpn_swagger_engine'
gem 'bcrypt'
gem 'easy_cipher', '~>0.9.1'
gem 'json'
gem 'kaminari'
gem 'lograge'
gem 'logstash-event'
gem 'okcomputer' # app monitoring
gem 'rpairtree'
gem 'rsync', '~>1.0.9'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'datagrid'
gem 'ettin'

group :production do
  gem 'mysql2'
end

group :development, :test do
  gem 'sqlite3'
  gem 'app_version_tasks'
  gem 'byebug'
  gem 'codeclimate-test-reporter'
  gem 'fabrication'
  gem 'faker'
  gem 'pry'
  gem 'pry-doc'
  gem 'rspec-activejob'
  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-rspec'
  gem 'simplecov'
  gem 'web-console'
  gem 'yard'
end

group :assets do
  gem 'sass-rails'
  gem 'uglifier'
  gem 'coffee-rails'
  gem 'therubyracer', platforms: :ruby
end

