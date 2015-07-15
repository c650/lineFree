require_relative "../../config/environment.rb"

class User < ActiveRecord::Base
	has_many :posts

	include BCrypt

	def password
		@password = Password.new(password_hash)
	end

	def password=(new_password)
		@password = Password.create(password_hash)
		self.password_hash = @password
	end
end