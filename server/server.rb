# # server.rb
require 'sinatra'
require 'json'

set :public_folder, '../client'

messages = []

get '/' do
    send_file File.join(settings.public_folder, 'index.html')
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