require 'pg'
require 'securerandom'
require 'BCrypt'

module RpsGame
  # def self.create_db_connection()
  #   cstring = {
  #     host: "localhost",
  #     dbname: "rps_game",
  #     user: "ruby",
  #     password: "rubyRailsJS"
    
  #   }

  #   PG.connect(string)
  # end

  def self.clear_tables(db)
    db.exec <<-SQL
      DELETE FROM users;
      DELETE FROM matches;
      DELETE FROM sessions;
      DELETE FROM games;
    SQL
  end

  def self.create_db_connection(dbname)
    PG.connect(host: 'localhost', dbname: dbname)
  end

  def self.create_tables(db)
    db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS users(
        id SERIAL PRIMARY KEY,
        username VARCHAR,
        password VARCHAR,
        score INTEGER
        );
      CREATE TABLE IF NOT EXISTS matches(
        id SERIAL PRIMARY KEY,
        hash VARCHAR,
        player_one_id INTEGER REFERENCES users(id)
          ON DELETE CASCADE
          ON UPDATE CASCADE,
        player_one_move VARCHAR,
        player_two_id INTEGER REFERENCES users(id)
          ON DELETE CASCADE
          ON UPDATE CASCADE,
        player_two_move VARCHAR,
        winner INTEGER REFERENCES users(id)
          ON DELETE CASCADE
          ON UPDATE CASCADE
        );
      CREATE TABLE IF NOT EXISTS sessions(
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id)
          ON DELETE CASCADE
          ON UPDATE CASCADE,
        session_id VARCHAR
        );
      CREATE TABLE IF NOT EXISTS games(
        id SERIAL PRIMARY KEY,
        player_one_id INTEGER REFERENCES users(id)
          ON DELETE CASCADE
          ON UPDATE CASCADE,
        player_two_id INTEGER REFERENCES users(id)
          ON DELETE CASCADE
          ON UPDATE CASCADE,
        winner INTEGER REFERENCES users(id)
          ON DELETE CASCADE
          ON UPDATE CASCADE
        );
    SQL
  end

  def self.drop_tables(db)
    db.exec <<-SQL
      DROP TABLE games;
      DROP TABLE matches;
      DROP TABLE sessions;
      DROP TABLE users;
    SQL
  end

  def self.seed_tables(db)
    db.exec <<-SQL

    SQL
  end
end

require_relative 'repos/users_repo'
require_relative 'repos/matches_repo'
