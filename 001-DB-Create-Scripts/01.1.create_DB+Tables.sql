--create DATABASE with set parameters.
CREATE DATABASE [SMA_final]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'SMA_final', FILENAME = N'C:\SQL-Kurs\project_right\scripts_gen\SMA_final.mdf' , SIZE = 8192KB , FILEGROWTH = 10%)
 LOG ON 
( NAME = N'SMA_final_log', FILENAME = N'C:\SQL-Kurs\project_right\scripts_gen\SMA_final_log.ldf' , SIZE = 8192KB , FILEGROWTH = 10%)
GO
ALTER DATABASE [SMA_final] SET COMPATIBILITY_LEVEL = 150
GO
ALTER DATABASE [SMA_final] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [SMA_final] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [SMA_final] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [SMA_final] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [SMA_final] SET ARITHABORT OFF 
GO
ALTER DATABASE [SMA_final] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [SMA_final] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [SMA_final] SET AUTO_CREATE_STATISTICS ON(INCREMENTAL = OFF)
GO
ALTER DATABASE [SMA_final] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [SMA_final] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [SMA_final] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [SMA_final] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [SMA_final] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [SMA_final] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [SMA_final] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [SMA_final] SET  DISABLE_BROKER 
GO
ALTER DATABASE [SMA_final] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [SMA_final] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [SMA_final] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [SMA_final] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [SMA_final] SET  READ_WRITE 
GO
ALTER DATABASE [SMA_final] SET RECOVERY FULL 
GO
ALTER DATABASE [SMA_final] SET  MULTI_USER 
GO
ALTER DATABASE [SMA_final] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [SMA_final] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [SMA_final] SET DELAYED_DURABILITY = DISABLED 
GO
USE [SMA_final]
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = Off;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = Primary;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = On;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = Primary;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = Off;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = Primary;
GO
USE [SMA_final]
GO
IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'PRIMARY') ALTER DATABASE [SMA_final] MODIFY FILEGROUP [PRIMARY] DEFAULT
GO




--create tables.
USE SMA_final


CREATE TABLE [user] (
user_id INTEGER NOT NULL IDENTITY(1, 1),
username NVARCHAR(50) NOT NULL UNIQUE,
first_name NVARCHAR(40) NULL,
last_name NVARCHAR(40) NULL,
email NVARCHAR(80) NOT NULL CONSTRAINT check_if_email_is_valid CHECK (CHARINDEX('@', [email]) > 0) UNIQUE,
--check if an @ is in the str
location NVARCHAR(40) NULL CONSTRAINT set_location_to_Unknown_if_NULL DEFAULT 'Unknown',
--set DEFAULT value if no location is set.
account_created DATE NOT NULL CONSTRAINT create_DATE_cant_be_in_future CHECK ([account_created] <= GETDATE()),
--compare account_created to current date
PRIMARY KEY ([user_id])
);


CREATE TABLE [post] (
post_id INT IDENTITY(1,1) PRIMARY KEY,
user_id INT NOT NULL,
FOREIGN KEY (user_id) REFERENCES [user](user_id),
post_text TEXT NOT NULL,
post_date DATETIME NOT NULL CONSTRAINT post_DATE_cant_be_in_future CHECK ([post_date] <= GETDATE()),
post_location NVARCHAR(50)		--could make new table with locations 
);


CREATE TABLE [comment] (
comment_id INT IDENTITY(1,1) PRIMARY KEY,
post_id INT NOT NULL,
FOREIGN KEY (post_id) REFERENCES post(post_id),
user_id INT NOT NULL,
FOREIGN KEY (user_id) REFERENCES [user](user_id),
comment_text TEXT NOT NULL,
comment_date DATETIME NOT NULL CONSTRAINT comment_DATE_cant_be_in_future CHECK ([comment_date] <= GETDATE())
);


CREATE TABLE [sentiment] (
sentiment_id INT IDENTITY(1,1) PRIMARY KEY,
post_id INT NOT NULL,
FOREIGN KEY (post_id) REFERENCES post(post_id),
sentiment_score DECIMAL(2,0) NOT NULL
);


CREATE TABLE [following] (
follower_id INT NOT NULL,
FOREIGN KEY (follower_id) REFERENCES [user](user_id),
followee_id INT NOT NULL,
FOREIGN KEY (followee_id) REFERENCES [user](user_id),
PRIMARY KEY (follower_id, followee_id)
);


CREATE TABLE [likes] (
like_id INT IDENTITY(1,1) PRIMARY KEY,
user_id INT NOT NULL,
FOREIGN KEY (user_id) REFERENCES [user](user_id),
post_id INT NOT NULL,
FOREIGN KEY (post_id) REFERENCES post(post_id),
like_date DATETIME NOT NULL CONSTRAINT like_DATE_cant_be_in_future CHECK ([like_date] <= GETDATE())
);


CREATE TABLE [shares] (
share_id INT IDENTITY(1,1) PRIMARY KEY,
user_id INT NOT NULL,
FOREIGN KEY (user_id) REFERENCES [user](user_id),
post_id INT NOT NULL,
FOREIGN KEY (post_id) REFERENCES post(post_id),
share_date DATETIME NOT NULL CONSTRAINT share_DATE_cant_be_in_future CHECK ([share_date] <= GETDATE())
--shared_to_platform NVARCHAR(255) NOT NULL		--add new fk to work around enum to youtube,twitter,etc....
);


CREATE TABLE [retweets] (
retweet_id INT IDENTITY(1,1) PRIMARY KEY,
user_id INT NOT NULL,
FOREIGN KEY (user_id) REFERENCES [user](user_id),
original_post_id INT NOT NULL,
FOREIGN KEY (original_post_id) REFERENCES post(post_id),
retweet_date DATETIME NOT NULL CONSTRAINT retweet_DATE_cant_be_in_future CHECK ([retweet_date] <= GETDATE())
);


CREATE TABLE [hashtags]  (
hashtag_id INT IDENTITY(1,1) PRIMARY KEY,
hashtag_text NVARCHAR(50) NOT NULL UNIQUE
);


CREATE TABLE [post_hashtags]  (
post_id INT NOT NULL,
FOREIGN KEY (post_id) REFERENCES post(post_id),
hashtag_id INT NOT NULL,
FOREIGN KEY (hashtag_id) REFERENCES hashtags(hashtag_id),
PRIMARY KEY (post_id, hashtag_id)
);

--words to be associated to be negative/positive to calculate sentiment later on.(demonstration purpose)
CREATE TABLE [sentiment_words] (
    word NVARCHAR(50),
    is_positive bit,
    is_negative bit
);