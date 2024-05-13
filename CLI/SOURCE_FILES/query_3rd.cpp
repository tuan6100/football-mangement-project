#include <query.h>

// select player_id, count(*) as count
// from player_statistic
// inner join player_profile on player_statistic.player_id = player_profile.player_id 
// inner join match on player_statics.match_id = match.match_id
// where player_profile.player_name = '...' and extract(year from match.date) >=  '...'
// group by 