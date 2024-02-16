# # server.rb
require 'sinatra'
require 'sinatra/activerecord'
require 'bcrypt'
require 'json'

enable :sessions

set :public_folder, '../client'
set :views, settings.root + '/client/views'

# Simplified error pipeline using a thread-safe queue
error_pipeline = Queue.new

# Medic class to handle errors
class Medic
  def initialize(pipeline)
    @pipeline = pipeline
    start_listening
  end

  def start_listening
    Thread.new do
      loop do
        handle_error(@pipeline.pop)
      end
    end
  end

  def handle_error(error_data)
    # Placeholder for error handling logic
    puts "Medic handling error: #{error_data}"
    # Add your error-handling logic here
  end
end

# Create an instance of the Medic
medic = Medic.new(error_pipeline)

class User < ActiveRecord::Base
    has_secure_password
end

class Message < ActiveRecord::Base
end

get '/register' do
    # erb :register
    send_file File.join(settings.public_folder, 'index.html')
end

post '/register' do
    user = User.new(username: params[:username], password: params[:password])
    if user.save
        redirect '/login'
    else
        # erb :register
        send_file File.join(settings.public_folder, 'index.html')
    end
end

get '/login' do
    # erb :login
    send_file File.join(settings.public_folder, 'index.html')
end

post '/login' do
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
        session[:user_id] = user.id
        redirect '/messages'
    else
        # erb :login
        send_file File.join(settings.public_folder, 'index.html') #login
    end
end

get '/logout' do
    session[:user_id] = nil
    redirect '/login'
end

get '/chat' do
    if session[:user_id]
        # erb :chat
        send_file File.join(settings.public_folder, 'index.html')
    else
        send_file File.join(settings.public_folder, 'index.html') #login
    end
end

get '/messages' do
    content_type :json
    messages.to_json
end

post '/messages' do
    begin
        message = {text: params[:message], time: Time.now.strftime("%Y-%m-%d %H:%M:%S")}
        messages.unshift(message)
        message.to_json
    rescue => e
        status 500
        { error: 'An error occurred while trying to create the message.' }.to_json
    end
end

# Path: server/server.rb
# # server.rb
# messages = []

# get '/' do
#     send_file File.join(settings.public_folder, 'index.html')
# end
