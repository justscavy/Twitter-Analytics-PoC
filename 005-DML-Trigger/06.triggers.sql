--create TRIGGER to update the posts and calculate the sentiment from it
CREATE TRIGGER trg_UpdatePost
ON [post]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @post_id INT, @post_text NVARCHAR(MAX);
    --check if post_text column was updated
    IF UPDATE(post_text)
    BEGIN
        --get text from table post
        SELECT @post_id = post_id, @post_text = post_text
        FROM [post]
        WHERE post_id IN (SELECT post_id FROM inserted);
        --execute proc. CalculateAndInsertSentiment if post was updated
        EXEC CalculateAndInsertSentiment @post_text, @post_id;
    END
END;


-----------------------------------------------------------------------


--create TRIGGER to avoid duplicates on post_id and hashtags
CREATE TRIGGER trg_UniqueHashtagsOnPosts
ON [post_hashtags]
INSTEAD OF INSERT
AS
BEGIN
    --check hashtags table if the combination of hashtag and post already exists
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        WHERE EXISTS (
            SELECT 1
            FROM [post_hashtags] ph
            WHERE ph.post_id = i.post_id
            AND ph.hashtag_id = i.hashtag_id
        )
    )
    BEGIN
        -- throw error if hashtag+post exists
        THROW 50001, 'Duplicates are not allowed.', 1;
    END
    ELSE
    BEGIN
        --if the post doesnt have the hashtag insert it
        INSERT INTO [post_hashtags] (post_id, hashtag_id)
        SELECT post_id, hashtag_id FROM INSERTED;
    END
END;


--INSERT INTO [post_hashtags] (post_id, hashtag_id)
--VALUES
--(1,42)

