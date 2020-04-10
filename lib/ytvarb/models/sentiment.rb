#! /opt/local/bin/ruby
# coding: utf-8

module Ytvarb
	module Model
		class Sentiment < ActiveRecord::Base
			establish_connection(CONN)

			unless connection.table_exists?('sentiments')
				connection.create_table(:sentiments, force: true) do |t|
					t.string  :sentiment, :null => false
					t.decimal :score, :null => false
					t.string  :emotional_phrase, :null => false

					t.string  :comment_id, :null => false
				end
			end
		end
	end
end
