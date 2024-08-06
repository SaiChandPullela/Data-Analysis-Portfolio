use ipl_player_analysis;
show tables;
SELECT 
    *
FROM
    ipl_batsman_stat;
SELECT 
    *
FROM
    ipl_bowler_stat;

-- sellect the data which we wanted work on

SELECT 
    COUNT(*) AS total_players
FROM
    ipl_batsman_stat;
-- 605 players have played IPL in total

SELECT 
    country, COUNT(player) AS player_count
FROM
    ipl_batsman_stat
WHERE
    country NOT LIKE '%India%'
GROUP BY country
ORDER BY player_count DESC;
-- So its australia with 81 players

SELECT 
    country, COUNT(player) AS player_count
FROM
    ipl_batsman_stat
WHERE
    country NOT LIKE '%India%'
GROUP BY country
ORDER BY player_count ASC;
-- Three countries Namibia, Netherlands and Nepal have one player each played in IPL

SELECT 
    id,
    player,
    country,
    matches,
    runs,
    batting_avg,
    batting_strike_rate
FROM
    ipl_batsman_stat
ORDER BY id , player;


-- Select the top 5 run getters in the history of tournamnet
SELECT 
    player, runs
FROM
    ipl_batsman_stat
ORDER BY runs DESC
LIMIT 5;
-- Who else scores more runs than King Kohli on his soil.

SELECT 
    player, runs
FROM
    ipl_batsman_stat
WHERE
    country LIKE 'India'
ORDER BY runs DESC
LIMIT 5;

-- let us rank the players based on their runs using RANK
select player, runs, player_rank from(
select player, runs, RANK() OVER (
order by runs desc) as player_rank
from ipl_batsman_stat) as ranked_batsman
where player_rank <=5;

-- select top 5 foreign run getters other than Indians
SELECT 
    player, runs
FROM
    ipl_batsman_stat
WHERE
    country NOT LIKE 'India'
ORDER BY runs DESC
LIMIT 5;
-- Its David Warner who scored most runs among the foreigners who played in IPL

SELECT 
    a.player,
    a.runs,
    ROUND((a.balls_faced / a.boundaries), 1) AS balls_taken_per_boundary
FROM
    ipl_batsman_stat AS a
        JOIN
    (SELECT 
        player, runs
    FROM
        ipl_batsman_stat
    ORDER BY runs DESC
    LIMIT 5) AS top_run_getters ON a.player = top_run_getters.player
ORDER BY balls_taken_per_boundary ASC , a.runs DESC;
-- So david warner usually takes as less as 5.4 deliveries to hit a boundary be it a 6 or 4 among the top 5 run scorers


SELECT 
    player, runs, batting_strike_rate
FROM
    ipl_batsman_stat
WHERE
    runs > 5000
ORDER BY batting_strike_rate DESC
LIMIT 10;

-- Now let us findout the top 5 scorers ordered according to their strike rates
SELECT 
    a.player, a.runs, a.batting_strike_rate
FROM
    ipl_batsman_stat AS a
        JOIN
    (SELECT 
        player, runs
    FROM
        ipl_batsman_stat
    ORDER BY runs DESC
    LIMIT 5) AS top_scorers ON a.player = top_scorers.player
ORDER BY a.batting_strike_rate DESC;
-- Who else can top this chart, the one who scores quick boundaries will have better strike rate quite often than not.

SELECT 
    top_average.player,
    top_average.runs,
    top_average.batting_avg
FROM
    ipl_batsman_stat AS top_average
        JOIN
    (SELECT 
        player, runs
    FROM
        ipl_batsman_stat
    ORDER BY runs DESC
    LIMIT 5) AS top_run_scorers ON top_average.player = top_run_scorers.player
ORDER BY top_average.batting_avg DESC;

SELECT player, runs, batting_avg, player_rank
FROM (
    SELECT player, runs, batting_avg,
           DENSE_RANK() OVER (ORDER BY batting_avg DESC) AS player_rank
    FROM ipl_batsman_stat
) AS ranked_batsmen
WHERE player_rank <= 5
ORDER BY player_rank ASC;

-- Now let us work on Bowlers data


SELECT 
    player, wickets
FROM
    ipl_bowler_stat
ORDER BY wickets DESC
LIMIT 5;
-- DJ Bravo from West Indies have picked more wickets than any body else.

SELECT 
    player, wickets, bowling_avg
FROM
    ipl_bowler_stat
WHERE
    player IN (SELECT 
            player
        FROM
            ipl_bowler_stat
        WHERE
            wickets > 150)
ORDER BY bowling_avg ASC
LIMIT 5;
-- These are the bowlers with more than 150 wickets and their averages
-- let us get a better result

SELECT 
    ipl_bowler_stat.player,
    ipl_bowler_stat.wickets,
    ipl_bowler_stat.bowling_avg
FROM
    ipl_bowler_stat
        JOIN
    (SELECT 
        player, wickets
    FROM
        ipl_bowler_stat
    ORDER BY wickets DESC
    LIMIT 5) AS top_wicket_takers ON ipl_bowler_stat.player = top_wicket_takers.player;
-- Right arm leg break bowler Amit Mishra is the one with best bowling average in the top 5 wicket takers list

-- Now let us use dense rank to rank them according to their average

WITH top_wicket_takers AS (
    SELECT player, wickets, bowling_avg
    FROM ipl_bowler_stat
    ORDER BY wickets DESC
    LIMIT 5
),
rank_table AS (
    SELECT player, wickets, bowling_avg, 
           DENSE_RANK() OVER (ORDER BY bowling_avg ASC) AS player_ranks
    FROM top_wicket_takers
)
SELECT a.player, a.wickets, a.bowling_avg, rank_table.player_ranks
FROM ipl_bowler_stat AS a
JOIN rank_table ON a.player = rank_table.player
ORDER BY rank_table.player_ranks ASC;



-- Now let us join both bowler table and batsman table and find the best all rounders
-- I just assume the criteria of minimum runs and wickets for batting all-rounders, bowling-allrounders 
-- and genuine-allrounders just based on my cricketing knowledge, because there is no certain criteria for being all-rounder.

SELECT 
    bat.player, bat.runs, bowl.wickets
FROM
    ipl_batsman_stat AS bat
        JOIN
    ipl_bowler_stat AS bowl ON bat.player = bowl.player
WHERE
    bat.runs >= 3000 AND bowl.wickets >= 50;

-- let us findout bowling all-rounders which mean players who have scored alteast 1000 runs and took more than 100 wickets

SELECT 
    bat.player, bat.runs, bowl.wickets
FROM
    ipl_batsman_stat AS bat
        JOIN
    ipl_bowler_stat AS bowl ON bat.player = bowl.player
WHERE
    bat.runs >= 1000 AND bowl.wickets >= 100;

-- Now let us findout genuine all-rounders which means players who have scored more than 2500 runs and pick atleast 100 wickets.

SELECT 
    bat.player, bat.runs, bowl.wickets
FROM
    ipl_batsman_stat AS bat
        JOIN
    ipl_bowler_stat AS bowl ON bat.player = bowl.player
WHERE
    bat.runs >= 2500 AND bowl.wickets >= 100;
-- Ravindra Jadeja is the only player in the IPL history to score more than 2500 runs and pick more than 100 wickets













