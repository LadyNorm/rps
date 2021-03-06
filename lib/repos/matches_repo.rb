module RpsGame
  class MatchesRepo
    def self.all(db)
      db.exec('SELECT * FROM matches').entries
    end

    def self.opponent_name(db, game_data)
      if (db.exec('SELECT * from matches WHERE hash = $1 AND player_one_id = $2', [game_data['hash'], game_data['player_id']]).entries.count > 0)
        db.exec('SELECT username FROM matches m JOIN users u ON u.id = m.player_two_id WHERE hash = $1 AND player_one_id = $2', [game_data['hash'], game_data['player_id']]).entries.first
      else
        db.exec('SELECT username FROM matches m JOIN users u ON u.id = m.player_one_id WHERE hash = $1 AND player_two_id = $2', [game_data['hash'], game_data['player_id']]).entries.first
      end
    end

    def self.matches_by_player(db, player_id)
      db.exec('SELECT * FROM matches WHERE player_one_id = $1 OR player_two_id = $1', [player_id]).entries
    end

    def self.matches_for_game(db, game_hash)
      db.exec('SELECT * FROM matches WHERE hash = $1', [game_hash]).entries
    end

    def self.create_game(db, players_info)
      game_hash = SecureRandom.hex(16)
      db.exec('INSERT INTO matches (hash, player_one_id, player_two_id) VALUES ($1, $2, $3)', [game_hash, players_info['player_one_id'], players_info['player_two_id']])
      {
        'game_hash' => game_hash,
        'player_one_id' => players_info['player_one_id'],
        'player_two_id' => players_info['player_two_id']
      }
    end

    def self.player_move(db, game_info, round_data)
      if ((round_data['player_one_move'] == 'rock' && round_data['player_two_move'] == 'scissors') || (round_data['player_one_move'] == 'paper' && round_data['player_two_move'] == 'rock') || (round_data['player_one_move'] == 'scissors' && round_data['player_two_move'] == 'paper'))
        winner = game_info['player_one_id']
      elsif ((round_data['player_two_move'] == 'rock' && round_data['player_one_move'] == 'scissors') || (round_data['player_two_move'] == 'paper' && round_data['player_one_move'] == 'rock') || (round_data['player_two_move'] == 'scissors' && round_data['player_one_move'] == 'paper'))
        winner = game_info['player_two_id']
      elsif round_data['player_one_move'] == round_data['player_two_move']
        winner = "tie"
      else
        raise 'Invalid player move.'
      end
        
      db.exec('INSERT INTO matches (hash, player_one_id, player_one_move, player_two_id, player_two_move, winner) VALUES ($1, $2, $3, $4, $5, $6)', [game_info['game_hash'], game_info['player_one_id'], round_data['player_one_move'], game_info['player_two_id'], round_data['player_two_move'], winner])

      RpsGame::MatchesRepo.scoreboard(db, game_info)

      # {
      #   'game_hash' => game_info['game_hash'],
      #   'player_one_id' => game_info['player_one_id'],
      #   'player_two_id' => game_info['player_two_id']
      # }
    end

    def self.scoreboard(db, game_info)
      player_one_score = db.exec('SELECT * FROM matches WHERE hash = $1 AND winner = $2', [game_info['game_hash'], game_info['player_one_id']]).entries.count
      player_two_score = db.exec('SELECT * FROM matches WHERE hash = $1 AND winner = $2', [game_info['game_hash'], game_info['player_two_id']]).entries.count
      if player_one_score == 3 || player_two_score == 3
        game_history = db.exec('SELECT * FROM matches WHERE hash = $1', [game_info['game_hash']]).entries

        RpsGame::GamesRepo.save(db, {
          'player_one_id' => game_info['player_one_id'],
          'player_two_id' => game_info['player_two_id'],
          'score' => "#{player_one_score} - #{player_two_score}",
          'winner' => player_one_score == 3 ? game_info['player_one_id'] : game_info['player_two_id']
          })
        db.exec('DELETE FROM matches WHERE hash = $1', [game_info['game_hash']])
      else
        {
          'player_one_score' => player_one_score,
          'player_two_score' => player_two_score
        }
      end
    end
  end
end