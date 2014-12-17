require 'pg'
module RpsGame
	def self.create_db_connection()
		cstring = {
  		host: "localhost",
  		dbname: "rps_game",
  		user: "ruby",
  		password: "rubyRailsJS"
		
		}

		PG.connect(cstring)
	end
	def self.clear_db(db)
	    db.exec <<-SQL
	      DELETE FROM users;
	      /* TODO: Clear rest of the tables (books, etc.) */
	    SQL
	end
		# NOTE: I am not indending the code you see here to actually be our final table structure. Just copying pasting what I had from my own attempt
	def self.create_tables(db)
	    db.exec <<-SQL	
	      CREATE TABLE users(
	        id SERIAL PRIMARY KEY,
	        username VARCHAR,
	        password VARCHAR,
	        score INTEGER
	        );
	    SQL
	    db.exec <<-SQL
	      CREATE TABLE game(
	        id SERIAL PRIMARY KEY,
	        start_time INTEGER,
	        end_time INTEGER,
	        user_one_id INTEGER,
	        user_two_id INTEGER,
	        );
	    SQL
	    db.exec <<-SQL
	     CREATE TABLE sessions(
	     	id SERIAL PRIMARY KEY,
	     	user_id REFERENCES user.id,
	     	sessionKey VARCHAR
	     	);
		SQL
	end
	def self.drop_tables(db)
	    db.exec <<-SQL
	      DROP TABLE users;
	      /* TODO: Drop rest of the tables (books, etc.) */
	    SQL
	end
end