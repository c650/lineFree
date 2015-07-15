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
    @place = Place.find_by(address: params[:search_term]) 
    @posts = Post.find_by(place_id: @place.id)
    erb :search_results
  end
###### LOGIN ######
  get '/login' do
      erb :login
  end

  post '/login' do
    @user = User.find_by(username: params[:username])
    if @user
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
    User.create(username: params[:username], first_name: params[:first_name], last_name: params[:last_name], email: params[:email], phone_number: params[:phone_number], birthdate: params[:birthdate])
    redirect to "/"
  end
###### NEW POST ######
  get '/new_post' do #working on logistics of this
    Post.create()
    erb :new_post
  end
  
  post '/new_post' do
    redirect to "/"
  end
###### NEW PLACE ######
  get '/new_place' do 
    Place.create(address: params[:address], name: params[:name], city: params[:city], state: params[:state], zipcode: params[:zipcode].to_i)
    erb :new_place
  end
  
  post '/new_place' do
    redirect to "/"
  end
###### LOGOUT ######
  get '/logout' do
    session[:user_id] = nil

    redirect '/'
  end

###### HELPER METHODS ######

  def current_user
    if logged_in?
      User.find(session[:user_id])
    else
      nil
    end
  end

  def logged_in?
    session[:user_id]
  end

end
