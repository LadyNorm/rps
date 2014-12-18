describe RpsGame::UsersRepo do

  def user_count(db)
    db.exec("SELECT COUNT(*) FROM users")[0]["count"].to_i
  end

  let(:db) { RpsGame.db('rps_test') }
  
  before(:each) do
    RpsGame.clear_tables(db)
  end


end