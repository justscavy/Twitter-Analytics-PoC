USE [SMA_final]
GO

/****** Object:  UserDefinedFunction [dbo].[sf_Anzahl_comments]    Script Date: 04.01.2024 08:50:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE OR ALTER FUNCTION [dbo].[sf_Anzahl_comments]
(
	-- Add the parameters for the function here
	@userID int,
	@Datum date
)
RETURNS int
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Anzahl_comments int
		SET @Anzahl_comments =
	(
		SELECT        COUNT(user_id)
			FROM      dbo.comment
			WHERE     (YEAR(comment_date) = YEAR(@Datum) AND (user_id = @userID))
	);

	IF @Anzahl_comments IS NULL
		SET @Anzahl_comments = 0;



	-- Return the result of the function
	RETURN @Anzahl_comments

END
GO

-------------------

USE [SMA_final];
GO

SELECT dbo.sf_Anzahl_comments (10, '2023-07-01') AS Anzahl_Comment; 
