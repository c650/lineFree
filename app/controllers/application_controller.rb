require_relative "../../config/environment.rb"
require_relative "../models/user.rb"
require_relative "../models/post.rb"
require_relative "../models/place.rb"
require_relative "../models/foursquare.rb"
require "geocoder"
require "httparty"
# require "pry"
require "sinatra/base"
require "sinatra/flash"

class ApplicationController < Sinatra::Base
  
  register Sinatra::Flash
  
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    set :sessions, true #starts up cookies and session saving
    set :session_secret, "please_don't_hack_me" #security measure
  end
###### ROOT ######
  get '/' do #needs error check if we don't have any post/places
    if Post.all != nil
      @posts = Post.all
    end
    if Place.all != nil
      @place = Place.all
    end
    erb :index
  end

###### SEARCH ######
  get '/search/' do
    @lat = params[:lat]
    @long = params[:lon]

    if (@lat == 0.0) || (@lat == nil)
      @lat = 25.605306
    end
    if (@long == 0.0) || (@long == nil)
      @long = -80.321098
    end

    @results = Neighborhood.new.search_query(@lat, @long , params[:search].capitalize)
    if (@results == nil) || (@results.empty?)
      redirect to '/'
    end
    @posts = Array.new
    @place = @results
    if @place.is_a? Array
      @place.each do |place|
        @posts.push(Post.find_by(place_id: place.id))
      end
    end
    erb :search_result
  end
###### USER PROFILE ######
  get '/user/:id' do
    @user = current_user
    erb :user_profile
  end
###### LOGIN ######
  get '/login' do
      erb :login
  end

  post '/login' do
    @user = User.find_by(username: params[:username])
    if @user == nil
      flash[:error] = "You need to create a new account."
      redirect  '/new_user'
    end
    if @user.password == params[:password]
      session[:user_id] = @user.id
      redirect '/'
    else
      flash[:error] = "Your username or password does not match those on your account."
      redirect '/login'
    end
  end
###### NEW USER ######
  get '/new_user' do
    erb :new_user
  end
  
  post '/new_user' do
    if check_birthday(params[:birthdate])
      @user = User.new(username: params[:username], first_name: params[:first_name], last_name: params[:last_name], email: params[:email], phone_number: params[:phone_number], birthdate: params[:birthdate], home_city: params[:home_city], home_state: params[:state])
      @user.password = params[:password]
      @user.save

      session[:user_id] = @user.id

      redirect to "/"
    else
      flash[:error] = "You are not old enough to sign up."
      redirect to "/"
    end
  end

###### NEW POST ######
  # get '/new_post' do #working on logistics of this
  #   if logged_in?
  #     erb :new_post
  #   else
  #     redirect to '/login'
  #   end
  # end
  
  post '/new_post' do
    @place = Place.find_by(address: params[:address])
    if @place != nil
      Post.create(user_id: session[:user_id], place_id: @place.id, wait_time: params[:wait_time], people_in_line: params[:people_in_line])
      redirect to "/"
    else 
      flash[:error] = "The place you were posting about doesn't exist in our records yet."
      redirect to '/new_place'
    end
  end
###### NEW PLACE ######
  get '/new_place' do 
    if logged_in?
      erb :new_place
    else
      redirect to '/'
    end
  end
  
  post '/new_place' do
    Place.create(address: params[:address], name: params[:name].downcase, city: params[:city].downcase, state: params[:state], zipcode: params[:zipcode].to_i)
    redirect to "/"
  end
###### LOGOUT ######
  get '/logout' do
    session[:user_id] = nil

    redirect '/'
  end

###### HELPER METHODS ######

  def current_user #method to get the current user
    if logged_in?
      User.find(session[:user_id])
    else
      nil
    end
  end

  def logged_in? #checks if logged in
    session[:user_id]
  end

  def check_birthday(birthdate) #checks to see if age is greater than or eq 16
    time_of_birth = birthdate.split('-')
    birthday = Time.new
    birthday = birthday.to_a
    birthday[3] = time_of_birth[2].to_i
    birthday[4] = time_of_birth[1].to_i
    birthday[5] = time_of_birth[0].to_i
    birthday = Time.utc(*birthday)
    age_check = birthday + 504911232

    if (Time.now - age_check) > 0 
      return true
    else
      return false
    end
  end

  def get_address(post)
    Place.find(post.place_id).address
  end

  def get_last_post(place)
    Post.find_by(place_id: place.id)
  end

end
