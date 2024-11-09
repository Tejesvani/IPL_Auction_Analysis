use Project_IPLSchema;

-- Simple Query
-- 1. Retrieving Top 10 batsman who has highest strike rate.
SELECT b.player_id, p.player_name, b.strike_rate  
FROM batsman b, player p
WHERE b.player_id = p.player_id
ORDER BY strike_rate DESC
LIMIT 10;

-- Simple Query
-- 2. Retrieving Top 10 Bowlers who have taken maximum no. of wickets
SELECT b.player_id, p.player_name, b.no_of_wickets
FROM bowler b, player p
WHERE b.player_id = p.player_id
ORDER BY no_of_wickets DESC
LIMIT 10;

-- Simple Query
-- 3. Retrieving the Top 10 Fielders in terms of their total wickets which is the sum of no.of run outs, no. of catches, no. of stumping.
SELECT f.player_id, p.player_name, f.no_of_catches, f.no_of_stumping,
f.no_of_run_out, f.no_of_catches+f.no_of_stumping+f.no_of_run_out as
total_wickets
FROM fielder f, player p
WHERE f.player_id = p.player_id
ORDER BY total_wickets DESC
LIMIT 10;

-- Aggregate
-- 4. Retrieve the average bid amount of each player 
SELECT p.player_id, p.player_name, AVG(b.bid_amount)
FROM player p , bid b, auction a
WHERE p.player_id = b.player_id
AND a.auction_id = b.auction_id    
GROUP BY b.player_id
ORDER BY player_id ASC;

-- Inner Join
-- 5. Retrieving all the players who are well versed in batting, bowling and fielding which is termed as all rounders.
SELECT a.player_id, p.player_name, a.batsman_id, a.bowler_id, a.fielder_id
FROM all_rounder a
JOIN player p ON a.player_id = p.player_id    
WHERE bowler_id IS NOT NULL
AND batsman_id IS NOT NULL
AND fielder_id IS NOT NULL;

-- Inner Join & CASE-WHEN
-- 6. Retrieving the players who have high demand and less demand for the corresponding auction years.
SELECT a.year, p.player_name, b.round_no,
    CASE
        WHEN b.round_no < 3 THEN 'High Demanded Player'
        WHEN b.round_no > 5 THEN 'Less Demanded Player'
        ELSE 'Normal Demanded Player'
    END AS demand_label
FROM auction a
JOIN bid b ON a.auction_id = b.auction_id
JOIN player p ON b.player_id = p.player_id
WHERE (b.round_no < 3 OR b.round_no > 5)
ORDER BY a.year desc, demand_label, b.round_no;

-- Nested
-- 7. Team with max wins
SELECT team_name, no_of_wins
FROM team
WHERE no_of_wins = (
			SELECT MAX(no_of_wins)
            		FROM team
		);

-- Correlated query
-- 8. Retrieve the player with the highest bid amount with their team name and the auction year
SELECT a.year, p.player_name, t.team_name, b1.bid_amount
FROM bid b1, auction a, player p, team t
WHERE b1.auction_id = a.auction_id
AND b1.player_id = p.player_id
AND b1.team_id = t.team_id
AND b1.bid_amount = (
    SELECT MAX(b2.bid_amount)
    FROM bid b2
    WHERE b2.auction_id = b1.auction_id
)
ORDER BY b1.auction_id;

-- ANY/ ALL
-- 9. Player who has played highest no. of seasons
SELECT b.player_id,p.player_name ,count(distinct b.auction_id)
FROM bid b,player p
WHERE p.player_id=b.player_id
GROUP BY b.player_id
HAVING COUNT(b.player_id) >= ALL (SELECT count(*)
						FROM bid b
						GROUP BY b.player_id
						);
                    

-- EXISTS / NOT EXIST
-- 10. Retrieving the players who has played all the seasons
SELECT player_id,player_name
FROM player p
WHERE NOT EXISTS
( SELECT *
FROM auction a
WHERE NOT EXISTS
(SELECT *
FROM bid b
WHERE p.player_id=b.player_id
AND a.auction_id=b.auction_id));

-- SET Operations
-- 11. Players exclusively specialized in batting and do not engage in bowling
SELECT p.player_id, p.player_name
FROM batsman b 
JOIN player p ON p.player_id=b.player_id 
EXCEPT
SELECT p.player_id, p.player_name
FROM bowler bl 
JOIN player p ON p.player_id = bl.player_id;

-- Subquery in SELECT/FROM
-- 12. Determine the players’ profit for the previous year by assessing the difference between the base price and the actual bid amount in the auction.
SELECT t.player_id,t.player_name,t.bid_amount, t.base_price, 
		t.bid_amount - t.base_price as player_profit
FROM (SELECT p.player_id, p.player_name, p.base_price, max(b.bid_amount) as bid_amount
FROM bid b, player p
WHERE b.player_id = p.player_id
AND b.auction_id = 6
GROUP BY p.player_id) AS t
ORDER BY player_profit desc;
