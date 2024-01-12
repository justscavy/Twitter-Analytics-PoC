--create a VIEW to get all posts by a specified user
CREATE VIEW UserPostsView AS
SELECT
    u.username,
    p.post_id,
    p.post_text,
    p.post_date
FROM
    [user] u
    JOIN post p ON u.user_id = p.user_id;


--SELECT *
--FROM UserPostsView
--WHERE username = 'Imani W. Odom';


---------------------------------------------------------------


--create a VIEW to see all users with all their activities by themselfs
CREATE VIEW All_user_activity AS
SELECT
    u.user_id,
    u.username,
    COUNT(DISTINCT p.post_id) AS post_count,
    COUNT(DISTINCT r.retweet_id) AS retweet_count,
    COUNT(DISTINCT s.share_id) AS share_count,
    COUNT(DISTINCT c.comment_id) AS comment_count,
    COUNT(DISTINCT l.like_id) AS like_count
FROM
    [user] u
LEFT JOIN
    post p ON u.user_id = p.user_id
LEFT JOIN
    retweets r ON u.user_id = r.user_id
LEFT JOIN
    shares s ON u.user_id = s.user_id
LEFT JOIN
    comment c ON u.user_id = c.user_id
LEFT JOIN
    likes l ON u.user_id = l.user_id
GROUP BY
    u.user_id, u.username;


--SELECT *
--FROM All_user_activity
--ORDER BY post_count + retweet_count + share_count + comment_count + like_count DESC;

----------------------------------------------------


--create a VIEW to search for a specified hashtag and show every post where its included
CREATE VIEW Search_Hashtag AS
SELECT
    ph.post_id,
    h.hashtag_text,
    p.user_id,
    u.username AS user_username,
    p.post_text
FROM
    post_hashtags ph
JOIN
    hashtags h ON ph.hashtag_id = h.hashtag_id
JOIN
    post p ON ph.post_id = p.post_id
JOIN
    [user] u ON p.user_id = u.user_id;


--SELECT *
--FROM Search_Hashtag
--WHERE hashtag_text = '#LustrousLagoon'
--ORDER BY hashtag_text;


-----------------------------------------------

--create VIEW to see posts and their sentiment score (needs the stored procedure to work)
CREATE VIEW SentimentView
AS
SELECT *
FROM sentiment


--select * from SentimentView
--ORDER BY Sentiment_score DESC;


--------------------------------------------------------------------------


--get every Hashtag
CREATE VIEW HashtagsView
AS
SELECT TOP 20
    h.hashtag_text,
    COUNT(ph.hashtag_id) AS hashtag_count
FROM
    [hashtags] h
JOIN
    [post_hashtags] ph ON h.hashtag_id = ph.hashtag_id
GROUP BY
    h.hashtag_text


--SELECT * FROM HashtagsView
--ORDER BY hashtag_count DESC;


-----------------------------------------------------------------------------


--get the top 20 of all Hashtags
CREATE VIEW HashtagsTOP20View
AS
SELECT TOP 20
    h.hashtag_text,
    COUNT(ph.hashtag_id) AS hashtag_count
FROM
    [hashtags] h
JOIN
    [post_hashtags] ph ON h.hashtag_id = ph.hashtag_id
GROUP BY
    h.hashtag_text


--SELECT * FROM HashtagsTOP20View
--ORDER BY hashtag_count DESC;









