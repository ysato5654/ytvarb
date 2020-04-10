#! /opt/local/bin/ruby
# coding: utf-8

require 'fileutils'
require 'logger'

module Ytvarb
	class YoutubeComment

		INDENT = "\s" * 49

		def initialize
			require File.expand_path(File.dirname(__FILE__) + '/model')

			logdev = ROOT_PATH + '/log'

			FileUtils.mkdir_p(logdev)

			logdev += '/log_file_' + Time.current.strftime('%Y%m%d_%H%M%S') + '.log'

			@logger = Logger.new(
				logdev,
				level = Logger::Severity::DEBUG,
				datetime_format = nil
				# => '%Y-%m-%dT%H:%M:%S.%06d '
			)

			@logger.datetime_format = '%Y-%m-%d %H:%M:%S %z '

			@logger.debug { "logger library version = #{Logger::VERSION}" }

			Ytvarb.configure do |config|
				@logger.debug {
					"configure" + "\n" +
					INDENT + "environment = #{config.environment}" + "\n" +
					INDENT + "api_key = #{config.api_key}" + "\n" +
					INDENT + "client_id = #{config.client_id}" + "\n" +
					INDENT + "client_secret = #{config.client_secret}" + "\n" +
					INDENT + "time_zone = #{config.time_zone}" + "\n" +
					INDENT + "year = #{config.year}" + "\n" +
					INDENT + "month = #{config.month}" + "\n" +
					INDENT + "day = #{config.day}" + "\n" +
					INDENT + "video_id = #{config.video_id}" + "\n" +
					INDENT + "adapter = #{Model::CONN[:adapter]}" + "\n" +
					INDENT + "database = #{Model::CONN[:database]}"
				}
			end
		end

		def get
			status = true

			api_key = ''
			video_id = nil

			Ytvarb.configure do |config|
				api_key = config.api_key
				video_id = config.video_id
			end

			@logger.info { "video id = #{video_id}" }

			youtube_api = Ytvarb::Api::Youtube.new(api_key, video_id)

			next_page_token = ''

			10.times do |i|

				# get comment from youtube video
				youtube_api.comment_threads(next_page_token)

				# response is error -> finish process
				if youtube_api.is_error?

					error = youtube_api.error

					@logger.error {
						"youtube api error" + "\n" +
						INDENT + "class = #{error[:class]}" + "\n" +
						INDENT + "detail = #{error[:detail]}" + "\n" +
						INDENT + "message = #{error[:message]}" + "\n" +
						INDENT + "type = #{error[:type]}"
					}

					STDERR.puts "#{__FILE__}:#{__LINE__}:Error: #{error[:class]} #{error[:detail]}"

					@logger.debug { "page_token = #{next_page_token}" }
					@logger.debug { "loop = #{i}" }

					status = false
					break
				end

				response = youtube_api.response

				@logger.info { "etag = #{response[:etag]}" }
				@logger.info { "next_page_token = #{response[:next_page_token]}" }
				@logger.debug { "total_results = #{response[:page_info][:total_results]}" }
				@logger.debug { "results_per_page = #{response[:page_info][:results_per_page]}" }

				# create record and save
				unless insert_comment_thread_record(response[:items])
					status = false
					break
				end

				next_page_token = response[:next_page_token]

			end

			@logger.close

			return status
		end

		def analyze
			status = true

			client_id = ''
			client_secret = ''
			video_id = nil

			Ytvarb.configure do |config|
				client_id = config.client_id
				client_secret = config.client_secret
				video_id = config.video_id
			end

			cotoha_api = Ytvarb::Api::Cotohaha.new(client_id, client_secret)

			# load comment from database
			Model::Comment.find_each do |comment|

				next if !Model::Sentiment.find_by(:comment_id => comment[:comment_id]).nil?

				# analyze youtube comment
				cotoha_api.sentiment(comment[:text_original])

				# response is error -> finish process
				if cotoha_api.is_error?
					STDERR.puts "#{__FILE__}:#{__LINE__}:Error: #{cotoha_api.response[:status]} #{cotoha_api.response[:message]}"

					status = false
					break
				end

				response = cotoha_api.response

				# create record and save if not found
				Model::Sentiment.find_or_create_by(:comment_id => comment[:comment_id]) do |_sentiment|
					_sentiment.sentiment        = response[:result][:sentiment]
					_sentiment.score            = response[:result][:score]
					_sentiment.emotional_phrase = response[:result][:emotional_phrase]
				end

				sleep(10)
			end

			return status
		end

		private
		def insert_comment_thread_record comment_thread_list
			comment_thread_list.each{ |comment_thread|

				# rename key (:id -> :comment_thread_id)
				if comment_thread.rename_key(old: :id, new: :comment_thread_id).nil?
					@logger.fatal { "#{File.basename(__FILE__)}:#{__LINE__}" }
					STDERR.puts "#{__FILE__}:#{__LINE__}:Fatal Error"

					@logger.debug { "comment_thread = #{comment_thread}" }

					return false
				end

				comment = comment_thread[:snippet][:top_level_comment]

				# rename key (:id -> :comment_id)
				if comment.rename_key(old: :id, new: :comment_id).nil?
					@logger.fatal { "#{File.basename(__FILE__)}:#{__LINE__}" }
					STDERR.puts "#{__FILE__}:#{__LINE__}:Fatal Error"

					@logger.debug { "comment = #{comment}" }

					return false
				end

				if comment[:snippet][:author_channel_id].nil?
					author_channel_id = nil
				else
					if comment[:snippet][:author_channel_id][:value].nil?
						author_channel_id = nil
					else
						author_channel_id = comment[:snippet][:author_channel_id][:value]
					end
				end

				comment_db = Model::Comment.find_or_create_by(:comment_id => comment[:comment_id]) do |comments|
					comments.kind = comment[:kind]
					comments.etag = comment[:etag]
					#comments.comment_id = comment[:comment_id], 
					comments.author_display_name = comment[:snippet][:author_display_name]
					comments.author_profile_image_url = comment[:snippet][:author_profile_image_url]
					comments.author_channel_url = comment[:snippet][:author_channel_url]
					comments.author_channel_id = author_channel_id.nil? ? :null : author_channel_id
					comments.channel_id = comment[:snippet][:channel_id].nil? ? :null : comment[:snippet][:channel_id]
					comments.video_id = comment[:snippet][:video_id]
					comments.text_display = comment[:snippet][:text_display]
					comments.text_original = comment[:snippet][:text_original]
					comments.parent_id = comment[:snippet][:parent_id].nil? ? :null : comment[:snippet][:parent_id]
					comments.can_rate = comment[:snippet][:can_rate]
					comments.viewer_rating = comment[:snippet][:viewer_rating]
					comments.like_count = comment[:snippet][:like_count]
					comments.moderation_status = comment[:snippet][:moderation_status].nil? ? :null : comment[:snippet][:moderation_status]
					comments.published_at = comment[:snippet][:published_at]
					comments.updated_at = comment[:snippet][:updated_at]
				end

				Model::CommentThread.find_or_create_by(:comment_thread_id => comment_thread[:comment_thread_id]) do |comment_threads|
					comment_threads.kind = comment_thread[:kind]
					comment_threads.etag = comment_thread[:etag]
					#comment_threads.comment_thread_id = comment_thread[:comment_thread_id]
					comment_threads.channel_id = comment_thread[:snippet][:channel_id].nil? ? :null : comment_thread[:snippet][:channel_id]
					comment_threads.video_id = comment_thread[:snippet][:video_id]
					comment_threads.can_reply = comment_thread[:snippet][:can_reply]
					comment_threads.total_reply_count = comment_thread[:snippet][:total_reply_count]
					comment_threads.is_public = comment_thread[:snippet][:is_public]
					comment_threads.comments_db_id = comment_db.id
				end

			}

			return true
		end
	end
end

class Hash
	def rename_key(old:, new:)
		return unless has_key?(old)
		return if has_key?(new)
		self[new] = self.delete(old)
		self
	end
end
