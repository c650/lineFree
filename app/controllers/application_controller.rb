require_relative "../../config/environment.rb"
require_relative "../models/fweet.rb"
require_relative "../models/user.rb"
class ApplicationController < Sinatra::Base
  
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    set :sessions, true #starts up cookies and session saving
    set :session_secret, "please_don't_hack_me" #security measure
  end

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

  get "/" do
    @users = User.all
    erb :index
  end
  
  post '/' do
    @users = User.all
    redirect to '/'
  end

  get '/new_user' do
    erb :new_user
  end
  
  post '/new_user' do
    User.create(username: params[:username], first_name: params[:first_name], last_name: params[:last_name])
    redirect to "/"
  end

  get '/logout' do
    session[:user_id] = nil

    redirect '/login'
  end

# HELPER METHODS

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
