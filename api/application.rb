# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/namespace'
require 'json'
require 'mongoid'
require_relative '../bot'


Dir['./errors/*.rb'].sort.each { |file| require file }
Dir['./models/*.rb'].sort.each { |file| require file }
Dir['./serializers/*.rb'].sort.each { |file| require file }

require_relative 'api'

Mongoid.load! 'mongoid.config'
Api.run!
