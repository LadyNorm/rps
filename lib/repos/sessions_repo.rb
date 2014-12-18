module RpsGame
  class SessionsRepo
    def self.create_session(db, user_id)
      session_id = SecureRandom.hex(16)
      db.exec('INSERT INTO sessions (user_id, session_id) VALUES ($1, $2) RETURNING user_id, session_id', [user_id, session_id]).first

    def self.end_session(db, user_data)
      db.exec('DELETE FROM sessions WHERE user_id = $1 AND session_id = $2', [user_data['id'], user_data['session_id']])
    end
  end
end