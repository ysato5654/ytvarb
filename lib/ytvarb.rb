#! /opt/local/bin/ruby
# coding: utf-8

require 'active_record'

require File.expand_path(File.dirname(__FILE__) + '/ytvarb/error')
require File.expand_path(File.dirname(__FILE__) + '/ytvarb/configure')
require File.expand_path(File.dirname(__FILE__) + '/ytvarb/api/cotohaha')
require File.expand_path(File.dirname(__FILE__) + '/ytvarb/api/youtube')
require File.expand_path(File.dirname(__FILE__) + '/ytvarb/youtube_comment')
require File.expand_path(File.dirname(__FILE__) + '/ytvarb/version')

module Ytvarb
	extend Configure

	ROOT_PATH = File.expand_path(File.dirname(__FILE__) + '/..')

	ENVIRONMENT = ['development', 'production']

	class << self
		def initialize env, video_id
			Ytvarb.reset

			Ytvarb.configure do |config|
				config.environment = env

				# api key
				filepath = ROOT_PATH + '/config/api_key.txt'
				raise NotFound.new(filepath) unless File.exist?(filepath)
				config.api_key = File.read(filepath)

				# client id
				filepath = ROOT_PATH + '/config/client_id.txt'
				raise NotFound.new(filepath) unless File.exist?(filepath)
				config.client_id = File.read(filepath)

				# client secret
				filepath = ROOT_PATH + '/config/client_secret.txt'
				raise NotFound.new(filepath) unless File.exist?(filepath)
				config.client_secret = File.read(filepath)

				config.time_zone = 'Tokyo'

				ActiveRecord::Base
				time = Time.current

				config.year = time.year
				config.month = time.month
				config.day = time.day

				config.video_id = video_id
			end
		end
	end
end
