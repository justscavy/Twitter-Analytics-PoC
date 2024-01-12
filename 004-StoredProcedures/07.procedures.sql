CREATE PROCEDURE AddUser
    @username NVARCHAR(50),
    @first_name NVARCHAR(40),
    @last_name NVARCHAR(40),
    @email NVARCHAR(80),
    @location NVARCHAR(40),
    @account_created DATE
AS
BEGIN
	--check if the user exists since username is unique
    IF EXISTS (SELECT 1 FROM [user] WHERE username = @username)
    BEGIN
	--try&catch OUTPUT
        PRINT 'Username already exists. Choose a different username.';
        RETURN;
    END
	--check if email address exists since email address has to be unique
    IF EXISTS (SELECT 1 FROM [user] WHERE email = @email)
    BEGIN
        PRINT 'Email address already exists. Choose a different email address.';
        RETURN;
	--if valid username & email proceed to insert
    END
    INSERT INTO [user] (username, first_name, last_name, email, location, account_created)
    VALUES (@username, @first_name, @last_name, @email, @location, @account_created);
    PRINT 'User created successfully.';
END;



--EXEC AddUser
--    @username = 'Testname',
--    @first_name = 'test_firstname',
--    @last_name = 'test_lastname',
--    @email = 'test@justatest.com',
--    @location = 'Testcity',
--    @account_created = '2023-01-01';


-------------------------------------------------------------


--create PROCEDURE to delete a user and its related data from all tables
CREATE PROCEDURE DeleteUserAndRelatedData
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if the user exists
    IF NOT EXISTS (SELECT 1 FROM [user] WHERE user_id = @user_id)
    BEGIN
        THROW 50001, 'User not found.', 1;
        RETURN;
    END;

	--delete from likes table
    DELETE FROM [likes] WHERE post_id IN (SELECT post_id FROM [post] WHERE user_id = @user_id);
    DELETE FROM [likes] WHERE user_id = @user_id;

	--delete from shares table
    DELETE FROM [shares] WHERE post_id IN (SELECT post_id FROM [post] WHERE user_id = @user_id);
    DELETE FROM [shares] WHERE user_id = @user_id;

	--delete from retweets table
    DELETE FROM [retweets] WHERE user_id = @user_id;

	--delete from comment table
    DELETE FROM [comment] WHERE post_id IN (SELECT post_id FROM [post] WHERE user_id = @user_id);
    DELETE FROM [comment] WHERE user_id = @user_id;

	--delete from following table 
    DELETE FROM [following] WHERE follower_id = @user_id OR followee_id = @user_id;

	--delete from post_hashtags table 
    DELETE FROM [post_hashtags] WHERE post_id IN (SELECT post_id FROM [post] WHERE user_id = @user_id);

	--delete from retweets table
    DELETE FROM [retweets] WHERE original_post_id IN (SELECT post_id FROM [post] WHERE user_id = @user_id);

	--delete from post table
    DELETE FROM [post] WHERE user_id = @user_id;

	--delete from sentiment table
	DELETE FROM [sentiment] WHERE post_id IN (SELECT post_id FROM [post] WHERE user_id = @user_id);

	--delete from user table
    DELETE FROM [user] WHERE user_id = @user_id;
	--OUTPUT
    PRINT 'User and related data deleted successfully.';
END;


--EXEC DeleteUserAndRelatedData
   -- @user_id = 123;


--------------------------------------------------------


--Calculate the Sentiment by words from table sentiment_words
--and insert them into sentiment table after calculating
CREATE PROCEDURE CalculateAndInsertSentiment
    @post_text NVARCHAR(MAX),
    @post_id INT
AS
BEGIN
    DECLARE @sentiment DECIMAL(2, 0) = 0;

    --split text into words
    DECLARE @words TABLE (word NVARCHAR(50));
    INSERT INTO @words
    SELECT value
    FROM STRING_SPLIT(@post_text, ' ');

    --calculate sentiment by adding +1 for each positive and subtracting -1 for each negative
    SELECT @sentiment = @sentiment +
        ISNULL(SUM(CASE WHEN p.word IS NOT NULL THEN 1 ELSE 0 END), 0) -
        ISNULL(SUM(CASE WHEN n.word IS NOT NULL THEN 1 ELSE 0 END), 0)
    FROM @words w
    LEFT JOIN [sentiment_words] p ON w.word = p.word AND p.is_positive = 1
    LEFT JOIN [sentiment_words] n ON w.word = n.word AND n.is_negative = 1;

    --set sentiment score from -100 - +100
    SET @sentiment = CASE WHEN @sentiment > 100 THEN 100
                         WHEN @sentiment < -100 THEN -100
                         ELSE @sentiment END;

    --Insert or update data into sentiment table
    MERGE INTO [sentiment] AS target
    USING (VALUES (@post_id, @sentiment)) AS source (post_id, sentiment_score)
    ON target.post_id = source.post_id
	--When exists update if not insert new row
    WHEN MATCHED THEN
        UPDATE SET sentiment_score = source.sentiment_score
    WHEN NOT MATCHED THEN
        INSERT (post_id, sentiment_score)
        VALUES (source.post_id, source.sentiment_score);
END;


------------------------------------------------------------------

--start inserting
DECLARE @post_id INT;
--iterare for every post_id from table [post]
DECLARE postCursor CURSOR FOR
SELECT post_id
FROM [post];
OPEN postCursor;
FETCH NEXT FROM postCursor INTO @post_id;
--if iteration is done BEGIN procedures
WHILE @@FETCH_STATUS = 0

BEGIN   
    DECLARE @post_text NVARCHAR(MAX);
    --get post_text from current id
    SELECT @post_text = post_text
    FROM [post]
    WHERE post_id = @post_id;
    --execute procedure
    EXEC CalculateAndInsertSentiment @post_text, @post_id;
    FETCH NEXT FROM postCursor INTO @post_id;
END
CLOSE postCursor;
DEALLOCATE postCursor;

--select * from sentiment
--order by sentiment_score DESC
