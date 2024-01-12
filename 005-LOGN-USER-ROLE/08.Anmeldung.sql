USE SMA_final;
GO
--create LOGINS to specify rights between users
CREATE LOGIN [Admin] WITH PASSWORD = 'admin';
CREATE LOGIN [User] WITH PASSWORD = 'user'

--create two users
CREATE USER [Admin] FOR LOGIN [Admin];
CREATE USER [User] FOR LOGIN [User];
GO

--set role Admin to have all rights and user to only have read rights
ALTER ROLE db_owner ADD MEMBER [Admin];
ALTER ROLE db_datareader ADD MEMBER [User];


--grant rights to users for every table
GRANT SELECT, INSERT, UPDATE, DELETE ON OBJECT::[user] TO [Admin];
GRANT SELECT ON OBJECT::[user] TO [User];

GRANT SELECT, INSERT, UPDATE, DELETE ON OBJECT::[post] TO [Admin];
GRANT SELECT ON OBJECT::[post] TO [User];

GRANT SELECT, INSERT, UPDATE, DELETE ON OBJECT::[comment] TO [Admin];
GRANT SELECT ON OBJECT::[comment] TO [User];

GRANT SELECT, INSERT, UPDATE, DELETE ON OBJECT::[sentiment] TO [Admin];
GRANT SELECT ON OBJECT::[sentiment] TO [User];

GRANT SELECT, INSERT, UPDATE, DELETE ON OBJECT::[following] TO [Admin];
GRANT SELECT ON OBJECT::[following] TO [User];

GRANT SELECT, INSERT, UPDATE, DELETE ON OBJECT::[likes] TO [Admin];
GRANT SELECT ON OBJECT::[likes] TO [User];

GRANT SELECT, INSERT, UPDATE, DELETE ON OBJECT::[shares] TO [Admin];
GRANT SELECT ON OBJECT::[shares] TO [User];

GRANT SELECT, INSERT, UPDATE, DELETE ON OBJECT::[retweets] TO [Admin];
GRANT SELECT ON OBJECT::[retweets] TO [User];

GRANT SELECT ON OBJECT::[hashtags] TO [Admin];
GRANT SELECT ON OBJECT::[hashtags] TO [User];

GRANT SELECT, INSERT, UPDATE, DELETE ON OBJECT::[post_hashtags] TO [Admin];
GRANT SELECT ON OBJECT::[post_hashtags] TO [User];

GRANT SELECT, INSERT, UPDATE, DELETE ON OBJECT::[sentiment_words] TO [Admin];
GRANT SELECT ON OBJECT::[sentiment_words] TO [User];
GO