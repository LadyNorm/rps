require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader'
require 'pry-byebug'
require 'bcrypt'
require 'json'

set :bind, '0.0.0.0'

#'lib/repos/user_repo.rb', 'lib/repos/game_repo.rb'
lib_files = ['lib/db_helper.rb']

lib_files.each do |f|
	require_relative f
	also_reload f
end

before do
	# if session['user_id']
	#   user_id = session['user_id']
	#   @db = RpsGame.create_db_connection
	#   @current_user = RpsGame::UsersRepo.find @db, user_id
	# else
	#   @current_user = {'username' => 'anonymous', 'id' => 1}
	# end
	@db = RpsGame.create_db_connection('rps_dev')
end

get '/' do
	erb :"index"
end

post '/signin' do
	# db = RpsGame.create_db_connection('rps_dev')
	user_data = {}
	user_data['username'] = params[:username]
	user_data['password'] = params[:password]
	JSON.generate(RpsGame::UsersRepo.sign_in(@db, user_data))
end

post '/signup' do
	# db = RpsGame.create_db_connection('rps_dev')
	user_data = {}
	user_data['username'] = params[:username]
	user_data['password'] = params[:password]
	JSON.generate(RpsGame::UsersRepo.sign_up(@db, user_data))
end

post '/signout' do
	# db = RpsGame.create_db_connection('rps_dev')
	user_data = {}
	user_data['id'] = localStorage['user_id']
	user_data['session_id'] = localStorage['session_id']
	JSON.generate(RpsGame::SessionsRepo.end_session(@db, user_data))
end

get '/online' do
	JSON.generate(RpsGame::UsersRepo.online_users(@db).to_a)
end