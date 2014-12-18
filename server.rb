require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader'
require 'pry-byebug'
require 'bcrypt'

set :bind, '0.0.0.0'

#'lib/repos/user_repo.rb', 'lib/repos/game_repo.rb'
lib_files = ['lib/db_helper.rb']

lib_files.each do |f|
	require_relative f
	also_reload f
end

before do
	if session['user_id']
	  user_id = session['user_id']
	  @db = RpsGame.create_db_connection
	  @current_user = RpsGame::UsersRepo.find @db, user_id
	else
	  @current_user = {'username' => 'anonymous', 'id' => 1}
	end
end

get '/' do
	erb :"index"
end