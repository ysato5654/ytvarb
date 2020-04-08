#! /opt/local/bin/ruby
# coding: utf-8

require 'google/apis/youtube_v3'

module Ytvarb
	module YoutubeDataApi
		YOUTUBE_SCOPE = 'https://www.googleapis.com'

		YOUTUBE_API_SERVICE_NAME = 'youtube'

		YOUTUBE_API_VERSION = 'v3'

		class CommentThread
			attr_reader :response

			PREFIX_URL = 'commentThreads'

			PART_LIMITATION = ['id', 'replies', 'snippet']

			DEFAULT_RESULTS = 20

			LOWER_MAX_RESULTS = 1

			UPPER_MAX_RESULTS = 100

			ORDER_LIMITATION = ['time', 'relevance']

			TEXT_FORMAT_LIMITATION = ['html', 'plainText']

			def initialize max_results = DEFAULT_RESULTS, page_token = ''
				@response = Hash.new

				unless max_results >= LOWER_MAX_RESULTS and max_results <= UPPER_MAX_RESULTS
					STDERR.puts "#{__FILE__}:#{__LINE__}:Warning: out of limitation. max results range is #{LOWER_MAX_RESULTS} ~ #{UPPER_MAX_RESULTS}."
				end

				#unless ORDER_LIMITATION.include?(order)
				#	STDERR.puts "#{__FILE__}:#{__LINE__}:Warning: out of limitation. currently support language are '#{ORDER_LIMITATION.join("' or '")}'."
				#end

				#unless TEXT_FORMAT_LIMITATION.include?(text_format)
				#	STDERR.puts "#{__FILE__}:#{__LINE__}:Warning: out of limitation. currently support language are '#{TEXT_FORMAT_LIMITATION.join("' or '")}'."
				#end

				auth_key = ''
				video_id = nil

				Ytvarb.configure do |config|
					auth_key = config.auth_key
					video_id = config.video_id
				end

				youtube = Google::Apis::YoutubeV3::YouTubeService.new

				youtube.key = auth_key

				youtube_comment_threads_list = youtube.list_comment_threads(
					PART_LIMITATION[2], # snippet
					max_results: max_results, 
					order: ORDER_LIMITATION[0], # time
					page_token: page_token, 
					text_format: TEXT_FORMAT_LIMITATION[1], # plainText
					video_id: video_id)
			end
		end
	end
end
