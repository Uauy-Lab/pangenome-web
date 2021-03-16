require 'yaml'
require 'set'

source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6'

# Use passenger in production
gem 'passenger'

# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
#gem 'sass-rails', '~> 5.0'
gem 'sassc-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views#
#gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
#gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
#gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
#gem 'sdoc', '~> 0.4.0', group: :doc


gem "webpacker"

gem 'jquery-ui-rails'

gem 'bio-samtools', '~>2.6'
gem 'redcarpet'
gem 'bio', '~>2'
#gem 'bio-polyploid-tools', '~>0.7.0'
gem 'bio-pangenome'
gem 'bio-gff3', '~>0.9.1'
gem 'bio-vcf'
gem 'sinatra'
#gem 'sequenceserver'

# preferences = YAML.load_file('./config/database.yml')

# adapters = Set.new
# preferences.each_pair do |k, v| 
# 	adapters << v["adapter"] 
#end


gem 'mysql2', '~> 0.5', :require => false #if adapters.include? "mysql2"
#gem 'pg', :require => false if adapters.include? "postgresql"


gem 'sequenceserver', :github => 'homonecloco/sequenceserver', :branch => 'update-sinatra'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'rails-erd', '~> 1.6.1'
end

