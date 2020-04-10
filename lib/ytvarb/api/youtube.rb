#! /opt/local/bin/ruby
# coding: utf-8

require 'google/apis/youtube_v3'

module Ytvarb
	module Api
		class Youtube
			attr_reader :response, :error

			def initialize api_key, video_id
				@response = Hash.new
				@error = Hash.new

				@api_key = api_key
				@video_id = video_id
			end

			def comment_threads page_token = ''

				youtube = Google::Apis::YoutubeV3::YouTubeService.new

				youtube.key = @api_key

				begin
					response = youtube.list_comment_threads('snippet', max_results: 100, order: 'time', page_token: page_token, text_format: 'plainText', video_id: @video_id)

					@response = response.to_h

				rescue Exception => e
					@error[:class] = e.class.to_s
					@error[:detail] = e.message.split(':').first
					@error[:message] = e.message.split(':').last.strip
					@error[:type] = e.status_code
				end
			end

			private
			def to_h
				keys = instance_variables.flat_map do |val_name| 
					getter_name = val_name[1..-1]
					respond_to?(getter_name) ? getter_name : []
				end

				keys.map { |key| [key.to_sym, public_send(key)] }.to_h
			end
		end
	end
end
