require_relative "../../config/environment.rb"

class Place < ActiveRecord::Base
	has_many :posts
end
