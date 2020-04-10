#! /opt/local/bin/ruby
# coding: utf-8

require 'yaml'
require 'fileutils'

module Ytvarb
	module Model
		yaml = YAML.load_file(ROOT_PATH + '/config/database.yml')

		environment = ''
		Ytvarb.configure do |config|
			environment = config.environment
		end

		database = yaml[environment]['database']

		Ytvarb.configure do |config|
			database.gsub!(/year/, config.year.to_s)
			database.gsub!(/month/, config.month.to_s.rjust(2, '0'))
			database.gsub!(/day/, config.day.to_s.rjust(2, '0'))
			database.gsub!(/video_id/, config.video_id)
		end

		FileUtils.mkdir_p(ROOT_PATH + '/' + File.dirname(database))

		CONN = {
			adapter: yaml[environment]['adapter'], 
			database: ROOT_PATH + '/' + database
		}

		require File.expand_path(File.dirname(__FILE__) + '/models/comment')
		require File.expand_path(File.dirname(__FILE__) + '/models/comment_thread')
		require File.expand_path(File.dirname(__FILE__) + '/models/sentiment')
	end
end
