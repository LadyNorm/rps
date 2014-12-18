module RpsGame
  class UsersRepo
    def self.all(db)
      #
      db.exec('SELECT * FROM users').entries
    end

    def self.get_id(db, username)
      db.exec('SELECT id FROM users WHERE username = $1', [username]).first['id']
    end

    def self.online_users(db)
      db.exec <<-SQL
        SELECT DISTINCT(u.username), u.score, u.id
        FROM users u
        JOIN sessions s
        ON s.user_id = u.id
      SQL
    end

    def self.sign_in(db, user_data)
      #
      user_return = db.exec('SELECT id, password FROM users WHERE username = $1', [user_data['username']]).first
      db_password = BCrypt::Password.new(user_return['password'])
      if db_password == user_data['password']
        RpsGame::SessionsRepo.create_session(db, user_return['id'])
      else
        return false
      end
    end

    def self.sign_up(db, user_data)
      # user_data['username'], ['password']
      check = db.exec('SELECT * FROM users WHERE username = $1', [user_data['username']]).first
      if check.nil?
        crypted_pw = BCrypt::Password.create(user_data['password'])
        user_id = db.exec('INSERT INTO users (username, password) VALUES ($1, $2) RETURNING id', [user_data['username'], crypted_pw]).first
        RpsGame::SessionsRepo.create_session(db, user_id['id'])
      else
        raise "Username already exists"
      end
    end

    def self.standings(db)
      db.exec <<-SQL
        SELECT username, score
        FROM users
        ORDER BY score DESC
      SQL
    end
  end
end