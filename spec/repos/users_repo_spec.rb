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

  # xit "finds a user" do
  #   user = RpsGame::UsersRepo.sign_in(db, { 'username' => 'Alice'} )
  #   retrieved_user = RpsGame::UsersRepo.find(db, user['id'] )

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

    # binding.pry

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
end