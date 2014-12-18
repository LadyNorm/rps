require 'spec_helper'

describe RpsGame::UsersRepo do

  def user_count(db)
    db.exec("SELECT COUNT(*) FROM users")[0]["count"].to_i
  end

  def session_count(db)
    db.exec("SELECT COUNT(*) FROM sessions")[0]["count"].to_i
  end

  let(:db) { RpsGame.db('rps_test') }
  
  before(:each) do
    RpsGame.clear_tables(db)
  end

  it "gets all users" do
    db.exec("INSERT INTO users (name, password, score) VALUES ($1, $2, $3)", ["Alice", "password_1", 4])
    db.exec("INSERT INTO users (name, password, score) VALUES ($1, $2, $3)", ["Bob", "password_2", -2])

    users = RpsGame::UsersRepo.all(db)
    expect(users).to be_a Array
    exepect(users.count).to eq 2

    usernames = users.map { |u| u['username'] }
    expect(usernames).to include "Alice", "Bob"
    
    passwords = users.map { |u| u['password'] }
    exepect(passwords).to include "password_1", "password_2"
    
    scores = users.map { |u| u['score'] }
    expect(scores).to include 4, -2 
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

    returned = RpsGame::UsersRepo.sign_up(db, user_data)

    check = db.exec("SELECT * FROM sessions")

    expect(returned).to eq check['session_id']

  end

end