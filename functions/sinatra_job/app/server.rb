require 'sinatra'

get '/' do
  erb :index
end

post '/messages' do
  content_type :json
  { message: params[:message] }.to_json
end
