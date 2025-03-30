
with deduped AS (
select * , row_number()over(partition by game_id, team_id, player_id  order by game_id ) AS row_num
from game_details)
select *
from deduped where row_num=1

