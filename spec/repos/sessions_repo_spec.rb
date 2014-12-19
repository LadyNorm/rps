require "spec_helper"
require 'pry-byebug'

describe RpsGame::SessionsRepo do

  def session_count(db)
    db.exec("SELECT COUNT(*) FROM sessions")[0]["count"].to_i
  end

  let(:db) { RpsGame.create_db_connection('rps_test') }
  
  before(:each) do
    RpsGame.clear_tables(db)
  end

  it "creates a session and deletes session" do
    expect(session_count(db)).to eq 0

    user_data_1 = {
      'username' => "Dora",
      'password' => "Explora"
    }
    sql = %q[
            INSERT INTO users (username, password)
            VALUES ($1, $2)
            RETURNING id
          ]

    user_id = db.exec(sql, [user_data_1['username'], user_data_1['password']]).first['id'].to_i

    user_data_pre = RpsGame::SessionsRepo.create_session(db, user_id)
    expect(session_count(db)).to eq 1

    user_data_2 = {
      'id' => user_data_pre["user_id"],
      'session_id' => user_data_pre["session_id"]
    }

    RpsGame::SessionsRepo.end_session(db, user_data_2)
    expect(session_count(db)).to eq 0
  end

  it "raises an error if user does not exist" do
    expect(session_count(db)).to eq 0
    urser_data = {
      'username' => 'princess',
      'password' => 'mononoke'
    }
    expect{ RpsGame::SessionsRepo.end_session(db, user_data) }.to raise_error
  end
  
end