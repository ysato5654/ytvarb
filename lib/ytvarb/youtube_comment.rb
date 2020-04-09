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

			Ytvarb.configure do |config|
				@logger.info { "video id = #{config.video_id}" }
			end

			max_results = 100
			next_page_token = ''

			loop_num = 0
			loop do
				# get comment
				api = Ytvarb::YoutubeDataApi::CommentThread.new(max_results, next_page_token)

				# response is error, then break
				unless api.error.empty?

					error = api.error

					@logger.error {
						"#{error[:class]}" + "\n" +
						INDENT + "detail = #{error[:detail]}" + "\n" +
						INDENT + "message = #{error[:message]}" + "\n" +
						INDENT + "type = #{error[:type]}"
					}

					STDERR.puts "#{__FILE__}:#{__LINE__}:Error: #{error[:class]} #{error[:detail]}"

					status = false
					break
				end

				response = api.response

				@logger.info { "etag = #{response[:etag]}" }
				@logger.info { "next_page_token = #{response[:next_page_token]}" }
				@logger.debug { "total_results = #{response[:page_info][:total_results]}" }
				@logger.debug { "results_per_page = #{response[:page_info][:results_per_page]}" }

				unless update_database(response)
					status = false
					break
				end

				next_page_token = response[:next_page_token]

				break if loop_num > 10

				loop_num += 1

			end

			@logger.close

			return status
		end

		def analyze
			return false
		end

		private
		def update_database response
			response[:items].each{ |comment_thread|

				if comment_thread.rename_key(old: :id, new: :comment_thread_id).nil?
					@logger.fatal { "#{File.basename(__FILE__)}:#{__LINE__}" }
					STDERR.puts "#{__FILE__}:#{__LINE__}:Fatal Error"

					return false
				end

				# update database
				if Model::CommentThread.find_by(:comment_thread_id => comment_thread[:comment_thread_id]).nil?

					comment = comment_thread[:snippet][:top_level_comment]

					if comment.rename_key(old: :id, new: :comment_id).nil?
						@logger.fatal { "#{File.basename(__FILE__)}:#{__LINE__}" }
						STDERR.puts "#{__FILE__}:#{__LINE__}:Fatal Error"

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

					comment_db = Model::Comment.create(
														:kind => comment[:kind], 
														:etag => comment[:etag], 
														:comment_id => comment[:comment_id], 
														:author_display_name => comment[:snippet][:author_display_name], 
														:author_profile_image_url => comment[:snippet][:author_profile_image_url], 
														:author_channel_url => comment[:snippet][:author_channel_url], 
														:author_channel_id => author_channel_id.nil? ? :null : author_channel_id, 
														:channel_id => comment[:snippet][:channel_id].nil? ? :null : comment[:snippet][:channel_id], 
														:video_id => comment[:snippet][:video_id], 
														:text_display => comment[:snippet][:text_display], 
														:text_original => comment[:snippet][:text_original], 
														:parent_id => comment[:snippet][:parent_id].nil? ? :null : comment[:snippet][:parent_id], 
														:can_rate => comment[:snippet][:can_rate], 
														:viewer_rating => comment[:snippet][:viewer_rating], 
														:like_count => comment[:snippet][:like_count], 
														:moderation_status => comment[:snippet][:moderation_status].nil? ? :null : comment[:snippet][:moderation_status], 
														:published_at => comment[:snippet][:published_at], 
														:updated_at => comment[:snippet][:updated_at]
													)

					Model::CommentThread.create(
												:kind => comment_thread[:kind], 
												:etag => comment_thread[:etag], 
												:comment_thread_id => comment_thread[:comment_thread_id], 
												:channel_id => comment_thread[:snippet][:channel_id].nil? ? :null : comment_thread[:snippet][:channel_id], 
												:video_id => comment_thread[:snippet][:video_id], 
												:can_reply => comment_thread[:snippet][:can_reply], 
												:total_reply_count => comment_thread[:snippet][:total_reply_count], 
												:is_public => comment_thread[:snippet][:is_public], 
												:comments_db_id => comment_db.id
											)
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
