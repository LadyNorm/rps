module RpsGame
  class UsersRepo
    def self.all(db)
      #
      db.exec('SELECT * FROM users')
    end

    def self.get_id(db, username)
      db.exec('SELECT id FROM users WHERE username = $1', [username]).first['id']
    end

    def self.sign_in(db, user_data)
      #
      user_return = db.exec('SELECT id, password FROM users WHERE username = $1', [user_data['username']]).first
      db_password = BCrypt::Password.new(user_return['password'])
      if db_password == user_data['password']
        session_id = SecureRandom.hex(16)
        db.exec('INSERT INTO sessions (user_id, session_id) VALUES ($1, $2)', [user_return['id'], session_id])
        session_id
      else
        return false
      end
    end

    def self.sign_out(db, user_data)
      #
      db.exec('DELETE FROM sessions WHERE user_id = $1 AND session_id = $2', [user_data['id'], user_data['session_id']])
    end

    def self.sign_up(db, user_data)
      # user_data['username'], ['password']
      check = db.exec('SELECT * FROM users WHERE username = $1', [user_data['username']]).first
      if check.nil?
        crypted_pw = BCrypt::Password.create(user_data['password'])
        user_id = db.exec('INSERT INTO users (username, password) VALUES ($1, $2) RETURNING id', [user_data['username'], crypted_pw]).first
        session_id = SecureRandom.hex(16)
        db.exec('INSERT INTO sessions (user_id, session_id) VALUES ($1, $2)', [user_id['id'], session_id])
        session_id
      else
        raise "Username already exists"
      end
    end
  end
end