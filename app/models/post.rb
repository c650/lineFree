require_relative "../../config/environment.rb" 

class Post < ActiveRecord::Base
	belongs_to :place
	belongs_to :user
end