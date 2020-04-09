#! /opt/local/bin/ruby
# coding: utf-8

module Ytvarb
	module Model
		class Comment < ActiveRecord::Base
			establish_connection(CONN)

			unless connection.table_exists?('comments')
				connection.create_table(:comments, force: true) do |t|
					t.string   :kind, :null => false
					t.string   :etag, :null => false
					t.string   :comment_id, :null => false

					# snippet
					t.string   :author_display_name, :null => false
					t.string   :author_profile_image_url, :null => false
					t.string   :author_channel_url, :null => false
					t.string   :author_channel_id, :null => true
					t.string   :channel_id, :null => true
					t.string   :video_id, :null => false
					t.string   :text_display, :null => false
					t.string   :text_original, :null => false
					t.string   :parent_id, :null => true
					t.boolean  :can_rate, :null => false
					t.string   :viewer_rating, :null => false
					t.integer  :like_count, :null => false
					t.string   :moderation_status, :null => true
					t.datetime :published_at, :null => false
					t.datetime :updated_at, :null => false

					t.timestamps
				end
			end
		end
	end
end
