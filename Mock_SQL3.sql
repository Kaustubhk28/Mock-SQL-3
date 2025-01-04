# Solution
with cte as
(
    select *,
        (   
            case
                when first_score > second_score then first_score
                when first_score < second_score then second_score
                when first_score = second_score and first_player < second_player then first_score
                when first_score = second_score and first_player > second_player then second_score
            end
        ) as high_score,
        (
            case
                when first_score > second_score then first_player
                when first_score < second_score then second_player
                when first_score = second_score and first_player < second_player then first_player
                when first_score = second_score and first_player > second_player then second_player
            end
        ) as high_score_player_id
        
    from Matches
),
cte2 as
(
    select p1.group_id, c.first_player, c.second_player, c.first_score, c.second_score, c.high_score, c.high_score_player_id,
    dense_rank() over(partition by p1.group_id order by c.high_score desc) as ranks
    from cte c
    join Players p1
    on p1.player_id = c.first_player
    union 
    select p2.group_id, c.first_player, c.second_player, c.first_score, c.second_score, c.high_score, c.high_score_player_id,
    dense_rank() over(partition by p2.group_id order by c.high_score desc) as ranks
    from cte c
    join Players p2
    on p2.player_id = c.second_player
)
select group_id, high_score_player_id as player_id
from cte2
where ranks = 1