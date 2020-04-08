#! /opt/local/bin/ruby
# coding: utf-8

require 'active_record'
require 'yaml'

require File.expand_path(File.dirname(__FILE__) + '/ytvarb/configure')
require File.expand_path(File.dirname(__FILE__) + '/ytvarb/youtube_data_api')
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
				config.auth_key = File.read(ROOT_PATH + '/config/auth_key.txt')
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

if $0 == __FILE__

	require 'pp'

	env = 'development'

	video_id = 'NypEG5G1EyM'

	Ytvarb.initialize(env, video_id)

	max_results = 2
	next_page_token = ''

	comment_thread = Ytvarb::YoutubeDataApi::CommentThread.new(max_results)
	pp comment_thread

end
