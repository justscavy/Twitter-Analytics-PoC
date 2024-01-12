--create scalar-valued function to get a sum
--of all posts shares likes etc of each user.
CREATE FUNCTION dbo.GetUserActivityCount(@user_id INT)
RETURNS INT
AS
BEGIN
	DECLARE @activityCount INT;
	
	SELECT @activityCount =
		COUNT(DISTINCT p.post_id) +
		COUNT(DISTINCT r.retweet_id) + 
		COUNT(DISTINCT s.share_id) +
		COUNT(DISTINCT c.comment_id) +
		COUNT(DISTINCT l.like_id)
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
WHERE u.user_id = @user_id;
RETURN ISNULL(@activityCount, 0);
END;


/*SELECT
	u.user_id,
	u.username,
	dbo.GetUserActivityCount(u.user_id) AS activity_count_total
FROM
	[user] u
ORDER BY activity_count_total DESC;
*/


-------------------------------------------------------------


--create Table-valued function to get every activity from specified user
CREATE FUNCTION GetUserActivityByUsername(@username VARCHAR(50))
RETURNS TABLE
AS
RETURN

(	--get posts
    SELECT
        'Post' AS Type,
        post_id AS ActivityID,
        post_text AS Content,
        post_date AS ActivityDate
    FROM post
    WHERE user_id = (SELECT user_id FROM [user] WHERE username = @username)
    UNION ALL

	--get comments
    SELECT 
        'Comment' AS Type,
        comment_id AS ActivityID,
        comment_text AS Content,
        comment_date AS ActivityDate
    FROM comment
    WHERE user_id = (SELECT user_id FROM [user] WHERE username = @username)
    UNION ALL

	--get likes
    SELECT
        'Like' AS Type,
        like_id AS ActivityID,
        NULL AS Content,
        like_date AS ActivityDate
    FROM likes
    WHERE user_id = (SELECT user_id FROM [user] WHERE username = @username)
    UNION ALL
	--get shares and set content to NULL
    SELECT 
        'Share' AS Type,
        share_id AS ActivityID,
        NULL AS Content,
        share_date AS ActivityDate
    FROM shares
    WHERE user_id = (SELECT user_id FROM [user] WHERE username = @username)
    UNION ALL
	--get retweets and set content to NULL
    SELECT 
        'Retweet' AS Type,
        retweet_id AS ActivityID,
        NULL AS Content,
        retweet_date AS ActivityDate
    FROM retweets
    WHERE user_id = (SELECT user_id FROM [user] WHERE username = @username)
);


--SELECT * FROM GetUserActivityByUsername('Imani W. Odom');


---------------------------------------------------------


--create Table-valued function to get every activity from every user
CREATE FUNCTION GetAllUserActivity()
RETURNS TABLE
AS
RETURN

(	--get posts
    SELECT 
        'Post' AS Type,
        post_id AS ActivityID,
		username AS UserName,
        post_text AS Content,
        post_date AS ActivityDate        
    FROM post
    INNER JOIN [user] ON post.user_id = [user].user_id
    UNION ALL
	--get comments
    SELECT 
        'Comment' AS Type,
        comment_id AS ActivityID,
		username AS UserName,
        comment_text AS Content,
        comment_date AS ActivityDate
    FROM comment
    INNER JOIN [user] ON comment.user_id = [user].user_id
    UNION ALL
	--get likes
    SELECT 
        'Like' AS Type,
        like_id AS ActivityID,
		username AS UserName,
        NULL AS Content,
        like_date AS ActivityDate       
    FROM likes
    INNER JOIN [user] ON likes.user_id = [user].user_id
    UNION ALL
	--get shares
    SELECT 
        'Share' AS Type,
        share_id AS ActivityID,
		username AS UserName,
        NULL AS Content,
        share_date AS ActivityDate        
    FROM shares
    INNER JOIN [user] ON shares.user_id = [user].user_id
    UNION ALL
	--get retweets
    SELECT 
        'Retweet' AS Type,
        retweet_id AS ActivityID,
		username AS UserName,
        NULL AS Content,
        retweet_date AS ActivityDate       
    FROM retweets
    INNER JOIN [user] ON retweets.user_id = [user].user_id
);


--SELECT * FROM GetAllUserActivity()
--ORDER BY UserName

