require "spec_helper"
require 'pry-byebug'

describe RpsGame::MatchesRepo do

  def user_count(db)
    db.exec("SELECT COUNT(*) FROM users")[0]["count"].to_i
  end

  def session_count(db)
    db.exec("SELECT COUNT(*) FROM sessions")[0]["count"].to_i
  end

  def match_count
    db.exec("SELECT COUNT(*) FROM matches")[0]["count"].to_i
  end

  let(:db) { RpsGame.create_db_connection('rps_test') }
  
  before(:each) do
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

  
end