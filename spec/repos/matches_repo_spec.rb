require "spec_helper"

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

  end

  it "has correct logic for player moves" do
    expect(user_count(db)).to eq 2


  end

  
end