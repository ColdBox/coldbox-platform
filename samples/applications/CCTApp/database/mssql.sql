/****** Object:  Table [dbo].[AppUser]    Script Date: 08/01/2007 16:00:13 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AppUser]') AND type in (N'U'))
DROP TABLE [dbo].[AppUser]
GO

/****** Object:  UserDefinedFunction [dbo].[newUUID]    Script Date: 08/01/2007 16:00:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[newUUID]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[newUUID]
GO

/****** Object:  UserDefinedFunction [dbo].[newUUID]    Script Date: 08/01/2007 15:23:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [newUUID](@GUID varchar(36))
RETURNS varchar(35)
AS
BEGIN
 RETURN left(@GUID, 23) + right(@GUID,12)
END
GO

/****** Object:  Table [dbo].[AppUser]    Script Date: 08/01/2007 15:23:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [AppUser](
	[AppUserId] [char](35) NOT NULL DEFAULT ([dbo].[newUUID](newid())),
	[Username] [varchar](30) NOT NULL,
	[Password] [char](32) NOT NULL,
	[FirstName] [varchar](50) NOT NULL,
	[LastName] [varchar](50) NOT NULL,
	[Email] [varchar](250) NOT NULL,
	[UpdatedOn] [datetime] NOT NULL DEFAULT (getdate()),
	[CreatedOn] [datetime] NOT NULL DEFAULT (getdate()),
	[isActive] [char](10) NOT NULL DEFAULT ((0)),
PRIMARY KEY CLUSTERED 
(
	[AppUserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF


INSERT INTO [AppUser]
           ([AppUserId]
           ,[Username]
           ,[Password]
           ,[FirstName]
           ,[LastName]
           ,[Email]
           ,[isActive])
     VALUES
			('E0DC3A63-E37C-4BDC-9B8C314C0982E203',
			'admin',
			'21232F297A57A5A743894A0E4A801FC3',
			'Admin',
			'MSSQL',
			'admin@admin.com',
			1)