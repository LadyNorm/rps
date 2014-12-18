require 'securerandom'

module RpsGame
  class UsersRepo
    def self.find db, user_id
      sql = %q[SELECT * FROM users WHERE id = $1]
      result = db.exec(sql, [user_id])
      result.first
    end
  end
end