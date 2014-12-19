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

get '/standings' do
	JSON.generate(RpsGame::UsersRepo.standings(@db).to_a)
end

post '/current_games' do
	games = RpsGame::MatchesRepo.matches_by_player(@db, params[:player_id])

	games.each do |game|
		game['opponent_username'] = RpsGame::MatchesRepo.opponent_name(@db, {'hash' => game["hash"], 'player_id' => params[:player_id]})['username']
		scores = RpsGame::MatchesRepo.scoreboard(@db, {'game_hash'=> game["hash"], 'player_one_id'=> params[:player_id], 'player_two_id'=> RpsGame::UsersRepo.get_id(@db, game['opponent_username'])})
		game['score'] = scores['player_one_score']
		game['opponent_score'] = scores['player_two_score']
	end

	JSON.generate(games)
end

get '/info/:player_id' do
	

	JSON.generate(RpsGame::GamesRepo.history(@db, params[:player_id]).to_a)
end

post '/new_game' do
	players_info = {}
	players_info['player_one_id'] = params[:player_one_id]
	players_info['player_two_id'] = params[:player_two_id]
	params[:user2_id]
	JSON.generate(RpsGame::MatchesRepo.create_game(@db, players_info))

end