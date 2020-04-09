#! /opt/local/bin/ruby
# coding: utf-8

module Ytvarb
	module Model
		class CommentThread < ActiveRecord::Base
			establish_connection(CONN)

			unless connection.table_exists?('comment_threads')
				connection.create_table(:comment_threads, force: true) do |t|
					t.string  :kind, :null => false
					t.string  :etag, :null => false
					t.string  :comment_thread_id, :null => false

					# snippet
					t.string  :channel_id, :null => true
					t.string  :video_id, :null => false
					t.boolean :can_reply, :null => false
					t.integer :total_reply_count, :null => false
					t.boolean :is_public, :null => false
					t.integer :comments_db_id, :null => false

					# replies
					# => not supported at current version

					t.timestamps
				end
			end
		end
	end
end
