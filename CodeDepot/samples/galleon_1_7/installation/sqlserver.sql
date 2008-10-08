if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[galleon_conferences]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[galleon_conferences]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[galleon_forums]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[galleon_forums]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[galleon_groups]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[galleon_groups]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[galleon_messages]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[galleon_messages]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[galleon_ranks]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[galleon_ranks]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[galleon_search_log]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[galleon_search_log]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[galleon_subscriptions]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[galleon_subscriptions]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[galleon_threads]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[galleon_threads]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[galleon_users]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[galleon_users]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[galleon_users_groups]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[galleon_users_groups]
GO

CREATE TABLE [dbo].[galleon_conferences] (
	[id] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[active] [bit] NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[galleon_forums] (
	[id] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[description] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[readonly] [bit] NOT NULL ,
	[active] [bit] NOT NULL ,
	[attachments] [bit] NOT NULL ,
	[conferenceidfk] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[galleon_groups] (
	[id] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[group] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[galleon_messages] (
	[id] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[title] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[body] [ntext] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[posted] [datetime] NOT NULL ,
	[useridfk] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[threadidfk] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[attachment] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[filename] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[galleon_ranks] (
	[id] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[name] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[minposts] [int] NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[galleon_search_log] (
	[searchterms] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[datesearched] [datetime] NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[galleon_subscriptions] (
	[id] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[useridfk] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[threadidfk] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[forumidfk] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
	[conferenceidfk] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[galleon_threads] (
	[id] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[name] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[readonly] [bit] NOT NULL ,
	[useridfk] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[forumidfk] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[datecreated] [datetime] NOT NULL ,
	[active] [bit] NOT NULL ,
	[sticky] [bit] NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[galleon_users] (
	[id] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[username] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[password] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[emailaddress] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[signature] [nvarchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[datecreated] [datetime] NOT NULL ,
	[confirmed] [bit] NOT NULL 
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[galleon_users_groups] (
	[useridfk] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[groupidfk] [nvarchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL 
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[galleon_conferences] WITH NOCHECK ADD 
	CONSTRAINT [PK_conferences] PRIMARY KEY  CLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[galleon_forums] WITH NOCHECK ADD 
	CONSTRAINT [PK_forums] PRIMARY KEY  CLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[galleon_groups] WITH NOCHECK ADD 
	CONSTRAINT [PK_groups] PRIMARY KEY  CLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[galleon_messages] WITH NOCHECK ADD 
	CONSTRAINT [PK_messages] PRIMARY KEY  CLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[galleon_ranks] WITH NOCHECK ADD 
	CONSTRAINT [PK_galleon_ranks] PRIMARY KEY  CLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[galleon_subscriptions] WITH NOCHECK ADD 
	CONSTRAINT [PK_subscriptions] PRIMARY KEY  CLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[galleon_threads] WITH NOCHECK ADD 
	CONSTRAINT [PK_threads] PRIMARY KEY  CLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO

ALTER TABLE [dbo].[galleon_users] WITH NOCHECK ADD 
	CONSTRAINT [PK_users] PRIMARY KEY  CLUSTERED 
	(
		[id]
	)  ON [PRIMARY] 
GO


insert into [dbo].[galleon_users](id,username,password,emailaddress,datecreated,confirmed,signature)
values('AD0CD90E-07C8-CFFE-F80C5EB6688AF47A','admin','admin','admin@127.0.0.1',getDate(),1,'')
GO

insert into [dbo].[galleon_groups](id,[group])
values('AD0EA988-0C8E-E2B3-DF0CF594C5DAAD63','forumsadmin')
GO

insert into [dbo].[galleon_groups](id,[group])
values('AD0F29B5-BEED-B8BD-CAA9379711EBF168','forumsmember')
GO

insert into [dbo].[galleon_groups](id,[group])
values('AD0F717C-AFE5-FD0E-77EB8FF5BDD858A2','forumsmoderator')
GO

insert into [dbo].[galleon_users_groups](useridfk,groupidfk)
values('AD0CD90E-07C8-CFFE-F80C5EB6688AF47A','AD0EA988-0C8E-E2B3-DF0CF594C5DAAD63')
go