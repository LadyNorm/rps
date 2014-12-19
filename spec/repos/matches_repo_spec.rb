require "spec_helper"
require 'pry-byebug'

describe RpsGame::MatchesRepo do

  def user_count(db)
    db.exec("SELECT COUNT(*) FROM users")[0]["count"].to_i
  end

  def session_count(db)
    db.exec("SELECT COUNT(*) FROM sessions")[0]["count"].to_i
  end

  def match_count(db)
    db.exec("SELECT COUNT(*) FROM matches")[0]["count"].to_i
  end

  let(:db) { RpsGame.create_db_connection('rps_test') }
  
  before(:each) do
    RpsGame.drop_tables(db)
    RpsGame.create_tables(db)
    RpsGame.clear_tables(db)
    # Add two players to users before each test
    sql1 = %q[
          INSERT INTO users (username, password)
          VALUES ($1, $2)
          RETURNING id
        ]
    sql2 = %q[
          INSERT INTO users (username, password)
          VALUES ($1, $2)
          RETURNING id
    ]
    @user_id_1 = db.exec(sql1, ['alice', 'wonderland']).first['id'].to_i
    @user_id_2 = db.exec(sql2, ['dora', 'explora']).first['id'].to_i
    @players_info = {
      'player_one_id' => @user_id_1,
      'player_two_id' => @user_id_2
    }

  end

  it "creates a game with two players" do
    expect(user_count(db)).to eq 2
    game_info = RpsGame::MatchesRepo.create_game(db, @players_info)
    expect(game_info).to be_a Hash
    expect(game_info['player_one_id']).to eq @user_id_1
    expect(game_info['player_two_id']).to eq @user_id_2
  end

  it "returns opponent name" do
    game_info = RpsGame::MatchesRepo.create_game(db, @players_info)
    game_hash = game_info['game_hash']
    result = RpsGame::MatchesRepo.opponent_name(db, game_hash)
    binding.pry
    expect(game_hash).to be_a Hash
  end


  it "gets all matches" do
    expect(user_count(db)).to eq 2
    game_info = RpsGame::MatchesRepo.create_game(db, @players_info)
    game_hash = game_info['game_hash']
    sql = %q[
            INSERT INTO matches (hash, player_one_id, player_one_move, player_two_id, player_two_move, winner)
            VALUES ($1, $2, $3, $4, $5, $6)
    ]
    db.exec(sql, [game_hash, @user_id_1, 'rock', @user_id_2, 'scissors', @user_id_1])
    all_matches = RpsGame::MatchesRepo.all(db).entries
    expect(all_matches).to be_a Array
    expect(match_count(db)).to eq 2
  end

  it "gets all matches of a specific game" do 
    expect(user_count(db)).to eq 2
    game_info = RpsGame::MatchesRepo.create_game(db, @players_info)
    game_hash = game_info['game_hash']
    round_data_1 = {
      'player_one_move' => 'rock',
      'player_two_move' => 'rock'
    }
    round_data_2 = {
      'player_one_move' => 'rock',
      'player_two_move' => 'rock'
    }
    round_data_3 = {
      'player_one_move' => 'rock',
      'player_two_move' => 'rock'
    }
    round_data_4 = {
      'player_one_move' => 'rock',
      'player_two_move' => 'rock'
    }
    RpsGame::MatchesRepo.player_move(db, game_info, round_data_1)
    RpsGame::MatchesRepo.player_move(db, game_info, round_data_2)
    RpsGame::MatchesRepo.player_move(db, game_info, round_data_3)
    RpsGame::MatchesRepo.player_move(db, game_info, round_data_4)

    result = RpsGame::MatchesRepo.matches_for_game(db, game_hash)

    expect(result).to be_a Array
    expect(result[0]).to be_a Hash
    expect(result.count).to eq 5
  end

  it "gets all matches belonging to one of two players" do
    expect(user_count(db)).to eq 2

    sql = %q[
      INSERT INTO users (username, password)
      VALUES ($1, $2)
      RETURNING id
    ]

    user_id_3 = db.exec(sql, ['gordon', 'ramsay']).first['id'].to_i
    user_id_4 = db.exec(sql, ['jamie', 'oliver']).first['id'].to_i
    players_info_aux = {
      'player_one_id' => user_id_3,
      'player_two_id' => user_id_4
    }

    game_info_1 = RpsGame::MatchesRepo.create_game(db, @players_info)
    game_info_2 = RpsGame::MatchesRepo.create_game(db, players_info_aux)
    game_hash_1 = game_info_1['game_hash']
    game_hash_2 = game_info_2['game_hash']
    round_data_1 = {
      'player_one_move' => 'rock',
      'player_two_move' => 'scissors'
    }
    round_data_2 = {
      'player_one_move' => 'paper',
      'player_two_move' => 'rock'
    }
    round_data_3 = {
      'player_one_move' => 'paper',
      'player_two_move' => 'rock'
    }
    round_data_4 = {
      'player_one_move' => 'paper',
      'player_two_move' => 'rock'
    }
    round_data_5 = {
      'player_one_move' => 'scissors',
      'player_two_move' => 'scissors'
    }
    RpsGame::MatchesRepo.player_move(db, game_info_1, round_data_1)
    RpsGame::MatchesRepo.player_move(db, game_info_1, round_data_2)
    RpsGame::MatchesRepo.player_move(db, game_info_2, round_data_3)
    RpsGame::MatchesRepo.player_move(db, game_info_2, round_data_4)
    RpsGame::MatchesRepo.player_move(db, game_info_2, round_data_5)

    result_1 = RpsGame::MatchesRepo.matches_by_player(db, @user_id_1)
    result_2 = RpsGame::MatchesRepo.matches_by_player(db, @user_id_2)
    result_3 = RpsGame::MatchesRepo.matches_by_player(db, user_id_3)
    result_4 = RpsGame::MatchesRepo.matches_by_player(db, user_id_4)

    expect(result_1).to be_a Array 
    expect(result_2.count).to eq 3
    expect(result_3.count).to eq 4

  end

  it "logs player moves and correctly determines a winner" do
    expect(user_count(db)).to eq 2
    game_info = RpsGame::MatchesRepo.create_game(db, @players_info)
    game_hash = game_info['game_hash']
    round_data = {
      'player_one_move' => 'rock',
      'player_two_move' => 'scissors'
    }
    RpsGame::MatchesRepo.player_move(db, game_info, round_data)
    winner = db.exec("SELECT winner FROM matches WHERE hash = $1", [game_hash]).entries.pop
    expect(winner['winner'].to_i).to eq @user_id_1
  end

  it "correctly returns the current score of a game" do
    expect(user_count(db)).to eq 2
    game_info = RpsGame::MatchesRepo.create_game(db, @players_info)
    game_hash = game_info['game_hash']
    round_data_1 = {
      'player_one_move' => 'rock',
      'player_two_move' => 'scissors'
    }
    round_data_2 = {
      'player_one_move' => 'rock',
      'player_two_move' => 'rock',
    }
    round_data_3 = {
      'player_one_move' => 'scissors',
      'player_two_move' => 'paper'
    }
    RpsGame::MatchesRepo.player_move(db, game_info, round_data_1)
    RpsGame::MatchesRepo.player_move(db, game_info, round_data_2)
    RpsGame::MatchesRepo.player_move(db, game_info, round_data_3)

    result = RpsGame::MatchesRepo.scoreboard(db, game_info)
    expect(result['player_one_score']).to eq 2
    expect(result['player_two_score']).to eq 0

    round_data_4 = {
      'player_one_move' => 'paper',
      'player_two_move' => 'rock'
    }
    RpsGame::MatchesRepo.player_move(db, game_info, round_data_4)
    RpsGame::MatchesRepo.scoreboard(db, game_info)

    game_result = db.exec("SELECT * FROM games").entries.first

    expect(game_result['winner']).to eq @user_id_1.to_s
    expect(match_count(db)).to eq 0
  end

  it "raises an error if player move is invalid" do
    expect(user_count(db)).to eq 2
    game_info = RpsGame::MatchesRepo.create_game(db, @players_info)
    game_hash = game_info['game_hash']
    round_data_1 = {
      'player_one_move' => 'knife',
      'player_two_move' => 'scissors'
    }
    round_data_2 = {
      'player_one_move' => 'rock',
      'player_two_move' => 'gun',
    }
    expect{ RpsGame::MatchesRepo.player_move(db, game_info, round_data_1) }.to raise_error
    expect{ RpsGame::MatchesRepo.player_move(db, game_info, round_data_2) }.to raise_error
  end
end