require "spec_helper"

describe RpsGame::MatchesRepo do

  def match_count
    db.exec("SELECT COUNT(*) FROM matches")[0]["count"].to_i
  end

  let(:db) { RpsGame.create_db_connection('rps_test') }
  
  before(:each) do
    RpsGame.clear_tables(db)
  end

  
end