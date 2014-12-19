require 'spec_helper'
require 'pry-byebug'

describe RpsGame::UsersRepo do

  def user_count(db)
    db.exec("SELECT COUNT(*) FROM users")[0]["count"].to_i
  end

  def session_count(db)
    db.exec("SELECT COUNT(*) FROM sessions")[0]["count"].to_i
  end

  let(:db) { RpsGame.create_db_connection('rps_test') }
  
  before(:each) do
    RpsGame.clear_tables(db)
  end

  it "gets all users" do
    db.exec("INSERT INTO users (username, password, score) VALUES ($1, $2, $3)", ["Alice", "password_1", 4])
    db.exec("INSERT INTO users (username, password, score) VALUES ($1, $2, $3)", ["Bob", "password_2", -2])

    users = RpsGame::UsersRepo.all(db).entries
    expect(users).to be_a Array
    expect(users.count).to eq 2

    usernames = users.map { |u| u['username'] }
    expect(usernames).to include "Alice", "Bob"
    
    passwords = users.map { |u| u['password'] }
    expect(passwords).to include "password_1", "password_2"
    
    scores = users.map { |u| u['score'] }
    expect(scores).to include "4", "-2" 
  end

  it "gets all online-users" do
    user_data_1 = {
      'username' => 'Alice',
      'password' => 'wonderland'
    }
    user_data_2 = {
      'username' => 'Jiminy',
      'password' => 'cricket'
    }
    user_data_3 = {
      'username' => 'project',
      'password' => '2501'
    }
    sql = %q[
          INSERT INTO users (username, password, score) 
          VALUES ($1, $2, $3)
          ]
    # db.exec(sql, ['Alice', 'wonderland', 0])
    # db.exec(sql, ['Jiminy', 'cricket', 0])
    db.exec(sql, ['project', '2501', 0])

    returned_1 = RpsGame::UsersRepo.sign_up(db, user_data_1)['session_id']
    returned_2 = RpsGame::UsersRepo.sign_up(db, user_data_2)['session_id']

    result = RpsGame::UsersRepo.online_users(db).entries

    expect(result.count).to eq 2
    online_users = result.map { |u| u['username'] }
    expect(online_users).to include 'Alice', 'Jiminy'
    response = RpsGame::UsersRepo.all(db).entries

    users = response.map { |u| u['username'] }
    expect(users).to include 'Alice', 'Jiminy', 'project'

  end

  it "signs up a user" do
    expect(user_count(db)).to eq 0
    expect(session_count(db)).to eq 0

    user_data = {
      'username' => 'Alice',
      'password' => 'password123'
    }

    returned = RpsGame::UsersRepo.sign_up(db, user_data)['session_id']
    check = db.exec("SELECT * FROM sessions").entries.first
    expect(returned).to eq check['session_id']

    expect(user_count(db)).to eq 1
    expect(session_count(db)).to eq 1
  end

  it "raises an error if you sign up with an exisiting username" do 
    user_data_1 = {
      'username' => 'Alice',
      'password' => 'password123'
    }
    RpsGame::UsersRepo.sign_up(db, user_data_1)

    user_data_2 = {
      'username' => 'Alice',
      'password' => 'password123'
    }

    expect{ RpsGame::UserRepo.sign_up(db, user_data_2) }.to raise_error

  end

  it "signs up a user, also testing signout/in" do

    expect(user_count(db)).to eq 0
    expect(session_count(db)).to eq 0

    user_data = {
      'username' => 'Alice',
      'password' => 'password123'
    }

    returned_1 = RpsGame::UsersRepo.sign_up(db, user_data)["session_id"]
    expect(user_count(db)).to eq 1
    expect(session_count(db)).to eq 1

    user_id = RpsGame::UsersRepo.get_id(db, user_data['username'])

    user_data_2 = {
      'id' => user_id,
      'session_id' => returned_1
    }

    RpsGame::SessionsRepo.end_session(db, user_data_2)
    expect(user_count(db)).to eq 1
    expect(session_count(db)).to eq 0

    returned_2 = RpsGame::UsersRepo.sign_in(db, user_data)["session_id"]
    check = db.exec("SELECT * FROM sessions").entries.first
    expect(returned_2).to eq check['session_id']

    expect(user_count(db)).to eq 1
    expect(session_count(db)).to eq 1
  end

  it "properly reports the standings" do
    user_1 = ['Alice', 'wonderland', 4]
    user_2 = ['Bob', 'builder', 2]
    user_3 = ['Duevyn', 'Cooke', 17]
    user_4 = ['tie', 'guy', 4]
    sql = %q[
            INSERT INTO users (username, password, score)
            VALUES ($1, $2, $3)
          ]
    db.exec(sql, user_1)
    db.exec(sql, user_2)
    db.exec(sql, user_3)
    db.exec(sql, user_4)

    result = RpsGame::UsersRepo.standings(db).entries
    expect(result[0]['username']).to eq "Duevyn"
    expect(result[1]['username']).to eq "Alice"
    expect(result[2]['username']).to eq "tie"
    expect(result[3]['username']).to eq "Bob"
  end
end