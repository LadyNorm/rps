require 'spec_helper'
require 'pry-byebug'

describe RpsGame::GamesRepo do

  def user_count(db)
    db.exec("SELECT COUNT(*) FROM users")[0]["count"].to_i
  end

  def session_count(db)
    db.exec("SELECT COUNT(*) FROM sessions")[0]["count"].to_i
  end

  def match_count(db)
    db.exec("SELECT COUNT(*) FROM matches")[0]["count"].to_i
  end

  def game_count(db)
    db.exec("SELECT COUNT(*) FROM games")[0]["count"].to_i
  end

  let(:db) { RpsGame.create_db_connection('rps_test') }

  before(:each) do
    RpsGame.drop_tables(db)
    RpsGame.create_tables(db)
    RpsGame.clear_tables(db)
    # Add two players to users before each test
    sql = %q[
          INSERT INTO users (username, password)
          VALUES ($1, $2)
          RETURNING id
        ]
    @user_id_1 = db.exec(sql, ['alice', 'wonderland']).first['id'].to_i
    @user_id_2 = db.exec(sql, ['dora', 'explora']).first['id'].to_i
    @players_info = {
      'player_one_id' => @user_id_1,
      'player_two_id' => @user_id_2
    }
    @game_info = RpsGame::MatchesRepo.create_game(db, @players_info)
    @round_data = {
      'player_one_move' => 'scissors',
      'player_two_move' => 'paper'
    }
    RpsGame::MatchesRepo.player_move(db, @game_info, @round_data)
    RpsGame::MatchesRepo.player_move(db, @game_info, @round_data)
    RpsGame::MatchesRepo.player_move(db, @game_info, @round_data)
    # This implicitly tests RpsGame:GamesRepo.save(db, match_data)

  end

  it "saves a game when a player gets 3 matches won" do
    expect(game_count(db)).to eq 1
  end

  it "get the game history for a player" do
    result = RpsGame::GamesRepo.history(db, @user_id_1)
    # result = [{"id"=>"1", "player_one_id"=>"1", "player_two_id"=>"2", "score"=>"3 - 0", "winner"=>"1"}]
    expect(result).to be_a Array
    expect(result.count).to eq 1
    expect(result[0]["score"]).to eq "3 - 0"
    expect(result[0]["winner"]).to eq @user_id_1.to_s
  end

  it "correctly calculates player score" do
    player_1_score = RpsGame::GamesRepo.calculate_score(db, @user_id_1)
    player_2_score = RpsGame::GamesRepo.calculate_score(db, @user_id_2)

    expect(player_1_score).to eq 1
    expect(player_2_score).to eq -1
  end
end