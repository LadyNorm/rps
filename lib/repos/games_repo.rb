module RpsGame
	class GamesRepo
    def self.history(db, player_id)
      db.exec('SELECT * FROM games WHERE player_one_id = $1 OR player_two_id = $1', [player_id]).entries
    end

    def self.calculate_score(db, player_id)
      wins = db.exec('SELECT * FROM games WHERE winner = $1', [player_id]).entries.count
      losses = ((RpsGame::GamesRepo.history(db, player_id).count) - wins)
      score = wins - losses

      RpsGame::UsersRepo.update_score(db, {
          'player_id' => player_id,
          'score' => score
        })
      score
    end

		def self.save(db, match_data)
      db.exec('INSERT INTO games (player_one_id, player_two_id, score, winner) VALUES ($1, $2, $3, $4) RETURNING *', [match_data['player_one_id'], match_data['player_two_id'], match_data['score'], match_data['winner']])

      RpsGame::GamesRepo.calculate_score(db, match_data['player_one_id'])
      RpsGame::GamesRepo.calculate_score(db, match_data['player_two_id'])
		end
	end
end
