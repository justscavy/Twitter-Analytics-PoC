USE SMA_final

--set NONCLUSTERED INDEX for each table.

CREATE NONCLUSTERED INDEX IX_username
ON [user] ([username]);

CREATE NONCLUSTERED INDEX IX_user_id_post
ON [post] (user_id);

CREATE NONCLUSTERED INDEX IX_post_id_comment
ON [comment] (post_id);

CREATE NONCLUSTERED INDEX IX_post_id_sentiment
ON [sentiment] (post_id);

CREATE NONCLUSTERED INDEX IX_user_id_likes
ON [likes] (user_id);

CREATE NONCLUSTERED INDEX IX_user_id_shares
ON [shares] (user_id);

CREATE NONCLUSTERED INDEX IX_user_id_retweets
ON [retweets] (user_id);

CREATE NONCLUSTERED INDEX IX_post_id_hashtags
ON [post_hashtags] (post_id);


CREATE NONCLUSTERED INDEX IX_word
ON [sentiment_words] (word);
