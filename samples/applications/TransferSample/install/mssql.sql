CREATE DATABASE [transfersample]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[users]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[users]
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[users]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
 BEGIN
CREATE TABLE [dbo].[users] (
	[id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF__users__id__7E6CC920] DEFAULT (newid()),
	[fname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[lname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[email] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[create_date] [datetime] NOT NULL CONSTRAINT [DF__users__create_da__7D78A4E7] DEFAULT (getdate()),
	 PRIMARY KEY  CLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
) ON [PRIMARY]
END

GO
INSERT INTO [transfersample].[dbo].[users]
           ([id]
           ,[fname]
           ,[lname]
           ,[email]
           ,[create_date])
     VALUES
           (newid()
           ,'admin'
           ,'admin'
           ,'admin@admin.com'
           ,getdate());