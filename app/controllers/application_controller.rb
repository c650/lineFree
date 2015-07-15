require 'Indirizzo'
require_relative "../../config/environment.rb"
require_relative "../models/user.rb"
require_relative "../models/post.rb"
require_relative "../models/place.rb"
class ApplicationController < Sinatra::Base
  
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    set :sessions, true #starts up cookies and session saving
    set :session_secret, "please_don't_hack_me" #security measure
  end
###### ROOT ######
  get "/" do
    @posts = Post.all
    @places = Place.all
    erb :index
  end
  
  post '/' do
    @posts = Post.all
    @places = Place.all
    redirect to '/'
  end
###### SEARCH ######
  post'/search/:search_term' do
    @place = Place.find_by(address: Indirizzo::Address.new(params[:search_term])) 
    @posts = Post.find_by(place_id: @place.id)
    erb :search_result
  end
###### LOGIN ######
  get '/login' do
      erb :login
  end

  post '/login' do
    @user = User.find_by(username: params[:username])
    if @user.password == params[:password]
      session[:user_id] = @user.id
      redirect to '/'
    else
      redirect to '/login'
    end
  end
###### NEW USER ######
  get '/new_user' do
    erb :new_user
  end
  
  post '/new_user' do
    @user = User.new(username: params[:username], first_name: params[:first_name], last_name: params[:last_name], email: params[:email], phone_number: params[:phone_number], birthdate: params[:birthdate])
    @user.password = params[:password]
    @user.save

    session[:user_id] = @user.id

    redirect to "/"
  end
###### NEW POST ######
  get '/new_post' do #working on logistics of this
    if logged_in?
      erb :new_post
    else
      redirect to '/login'
    end
  end
  
  post '/new_post' do
    Post.create()
    redirect to "/"
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
    Place.create(address: Indirizzo::Address.new(params[:search_term]), name: params[:name].downcase, city: params[:city].downcase, state: params[:state], zipcode: params[:zipcode].to_i)
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
    time_of_birth = birthdate.split('/')
    birthday = Time.new
    birthday.month = time_of_birth[0]
    birthday.day = time_of_birth[1]
    birthday.year = time_of_birth[2]

    age_check = birthday + 504911232

    if (Time.now - age_check) > 0 
      return true
    else
      return false
    end
  end

end
