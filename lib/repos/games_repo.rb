module RpsGame
	class GamesRepo
    def self.history(db, player_id)
      db.exec('SELECT * FROM games WHERE player_one_id = $1 OR player_two_id = $1', [player_id]).entries
    end

		def self.save(db, match_data)
      db.exec('INSERT INTO games (player_one_id, player_two_id, score, winner) VALUES ($1, $2, $3, $4) RETURNING *', [match_data['player_one_id'], match_data['player_two_id'], match_data['score'], match_data['winner']])
		end
	end
end
