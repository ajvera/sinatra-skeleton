require 'rake'

require ::File.expand_path('../config/environment', __FILE__)

# Include all of ActiveSupport's core class extensions, e.g., String#camelize
require 'active_support/core_ext'

namespace :generate do
  desc "Create an empty model in app/models, e.g., rake generate:model NAME=User"
  task :model do
    unless ENV.has_key?('NAME')
      raise "Must specificy model name, e.g., rake generate:model NAME=User"
    end

    model_name     = ENV['NAME'].camelize
    model_filename = ENV['NAME'].underscore + '.rb'
    model_path = APP_ROOT.join('app', 'models', model_filename)

    if File.exist?(model_path)
      raise "ERROR: Model file '#{model_path}' already exists"
    end

    puts "Creating #{model_path}"
    File.open(model_path, 'w+') do |f|
      if model_name == "User"
        f.write(<<-EOF.strip_heredoc)
          class User < ActiveRecord::Base

            def password
              @password ||= Bcrypt::Password.new(self.encrypted_password)
            end

            def password=(plaintext)
              @raw_password = plaintext
              self.encrypted_password = BCrypt::Password.create(plaintext)
            end

            def authenticate(args)
              user = User.find_by(email: args[:email])
              if user && user.password == args[:password]
                return user
              end
              nil
            end

            def password_is_valid
              if @raw_password.nil?
                errors.add("Password is required")
              elsif @raw_password.length < 8
                errors.add("Password must be 8 or more characters")
              end
            end

          end
        EOF
      else
        f.write(<<-EOF.strip_heredoc)
          class #{model_name} < ActiveRecord::Base
            # Remember to create a migration!
          end
        EOF
      end
    end
  end

  desc "Create an empty migration in db/migrate, e.g., rake generate:migration NAME=create_tasks"
  task :migration do
    unless ENV.has_key?('NAME')
      raise "Must specificy migration name, e.g., rake generate:migration NAME=create_tasks"
    end

    name     = ENV['NAME'].camelize
    filename = "%s_%s.rb" % [Time.now.strftime('%Y%m%d%H%M%S'), ENV['NAME'].underscore]
    path     = APP_ROOT.join('db', 'migrate', filename)

    if File.exist?(path)
      raise "ERROR: File '#{path}' already exists"
    end

    puts "Creating #{path}"
    File.open(path, 'w+') do |f|
      f.write(<<-EOF.strip_heredoc)
        class #{name} < ActiveRecord::Migration
          def change
          end
        end
      EOF
    end
  end

  desc "Create an empty model spec in spec, e.g., rake generate:spec NAME=user"
  task :spec do
    unless ENV.has_key?('NAME')
      raise "Must specificy migration name, e.g., rake generate:spec NAME=user"
    end

    name     = ENV['NAME'].camelize
    filename = "%s_spec.rb" % ENV['NAME'].underscore
    path     = APP_ROOT.join('spec', filename)

    if File.exist?(path)
      raise "ERROR: File '#{path}' already exists"
    end

    puts "Creating #{path}"
    File.open(path, 'w+') do |f|
      f.write(<<-EOF.strip_heredoc)
        require 'spec_helper'

        describe #{name} do
          pending "add some examples to (or delete) #{__FILE__}"
        end
      EOF
    end
  end
  desc "Create a template controller in controllers"
  task :controller do
    unless ENV.has_key?('NAME')
      raise "Must specify a controller name, e.g., rake generate:controller NAME=user"
    end

    name     = ENV['NAME']
    filename = "%s.rb" % ENV['NAME']
    path     = APP_ROOT.join('app/controllers', filename)
    p_name   = name.pluralize
    up_name  = p_name.capitalize

    if File.exist?(path)
      raise "ERROR: File '#{path}' already exists"
    end

    puts "Creating #{path}"
    File.open(path, 'w+') do |f|
      f.write(<<-EOF.strip_heredoc)
        get '/#{p_name}' do
          @#{p_name} = #{up_name}.all
          erb :'#{p_name}/index'
        end

        get '/#{p_name}/new' do
          #return an HTML form for creating a new #{p_name}
        end

        post '/#{p_name}' do
          #create a new #{p_name}
        end

        get '/#{p_name}/:id' do
          #display a specific article #{p_name}
        end

        get '/#{p_name}/:id/edit' do
          #return an HTML form for editing #{p_name}
        end

        put '/#{p_name}/:id' do
          # update a specific #{p_name}
        end

        delete '/#{p_name}/:id' do
          #delete a specific #{p_name}
        end
      EOF
    end
  end
end

namespace :db do
  desc "Drop, create, and migrate the database"
  task :reset => [:drop, :create, :migrate]

  desc "Create the databases at #{DB_NAME}"
  task :create do
    puts "Creating development and test databases if they don't exist..."
    system("createdb #{APP_NAME}_development && createdb #{APP_NAME}_test")
  end

  desc "Drop the database at #{DB_NAME}"
  task :drop do
    puts "Dropping development and test databases..."
    system("dropdb #{APP_NAME}_development && dropdb #{APP_NAME}_test")
  end

  desc "Migrate the database (options: VERSION=x, VERBOSE=false, SCOPE=blog)."
  task :migrate do
    ActiveRecord::Migrator.migrations_paths << File.dirname(__FILE__) + 'db/migrate'
    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths, ENV["VERSION"] ? ENV["VERSION"].to_i : nil) do |migration|
      ENV["SCOPE"].blank? || (ENV["SCOPE"] == migration.scope)
    end
  end

  desc "rollback your migration--use STEP=number to step back multiple times"
  task :rollback do
    step = (ENV['STEP'] || 1).to_i
    ActiveRecord::Migrator.rollback('db/migrate', step)
    Rake::Task['db:version'].invoke if Rake::Task['db:version']
  end

  desc "Populate the database with dummy data by running db/seeds.rb"
  task :seed do
    require APP_ROOT.join('db', 'seeds.rb')
  end

  desc "Returns the current schema version number"
  task :version do
    puts "Current version: #{ActiveRecord::Migrator.current_version}"
  end

  namespace :test do
    desc "Migrate test database"
    task :prepare do
      system "rake db:migrate RACK_ENV=test"
    end
  end
end

desc 'Start IRB with application environment loaded'
task "console" do
  exec "irb -r./config/environment"
end


# In a production environment like Heroku, RSpec might not
# be available.  To handle this, rescue the LoadError.
# https://devcenter.heroku.com/articles/getting-started-with-ruby-o#runtime-dependencies-on-development-test-gems
begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

task :default  => :spec
