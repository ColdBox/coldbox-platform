SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[coldboxreader_users]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[coldboxreader_users](
	[UserID] [varchar](50) NOT NULL,
	[UserName] [varchar](20) NOT NULL,
	[Password] [varchar](45) NOT NULL,
	[Email] [varchar](45) NOT NULL,
	[CreatedOn] [datetime] NOT NULL CONSTRAINT [DF_coldboxreader_users_CreatedOn]  DEFAULT (getdate()),
	[LastLogin] [datetime] NOT NULL CONSTRAINT [DF_coldboxreader_users_LastLogin]  DEFAULT (getdate()),

CONSTRAINT [PK_coldboxreader_users] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[coldboxreader_feed]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[coldboxreader_feed](
	[FeedID] [varchar](50) NOT NULL,
	[FeedName] [varchar](150) NOT NULL,
	[FeedURL] [varchar](500) NOT NULL,
	[FeedAuthor] [varchar](100) NOT NULL,
	[Description] [varchar](1000) NOT NULL,
	[ImgURL] [varchar](100) NULL,
	[SiteURL] [varchar](100) NOT NULL,
	[CreatedBy] [varchar](50) NOT NULL,
	[CreatedOn] [datetime] NOT NULL CONSTRAINT [DF_coldboxreader_feed_CreatedOn]  DEFAULT (getdate()),
	[LastRefreshedOn] [datetime] NOT NULL CONSTRAINT [DF_coldboxreader_feed_LastRefreshedOn]  DEFAULT (getdate()),
	[Views] [int] NOT NULL,
 CONSTRAINT [PK_coldboxreader_feed] PRIMARY KEY CLUSTERED 
(
	[FeedID] ASC
) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[coldboxreader_feed_tags]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[coldboxreader_feed_tags](
	[feed_tagID] [varchar](50) NOT NULL,
	[feedID] [varchar](50) NOT NULL,
	[tag] [varchar](45) NOT NULL,
	[CreatedBy] [varchar](50) NOT NULL,
	[CreatedOn] [datetime] NOT NULL CONSTRAINT [DF_coldboxreader_feed_tags_CreatedOn]  DEFAULT (getdate()),
 CONSTRAINT [PK_coldboxreader_feed_tags] PRIMARY KEY CLUSTERED 
(
	[feed_tagID] ASC
)ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sysforeignkeys WHERE constid = OBJECT_ID(N'[dbo].[FK_coldboxreader_feed_coldboxreader_users]') AND fkeyid = OBJECT_ID(N'[dbo].[coldboxreader_feed]'))
ALTER TABLE [dbo].[coldboxreader_feed]  WITH CHECK ADD  CONSTRAINT [FK_coldboxreader_feed_coldboxreader_users] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[coldboxreader_users] ([UserID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[coldboxreader_feed] CHECK CONSTRAINT [FK_coldboxreader_feed_coldboxreader_users]
GO
IF NOT EXISTS (SELECT * FROM sysforeignkeys WHERE constid = OBJECT_ID(N'[dbo].[FK_coldboxreader_feed_tags_coldboxreader_feed]') AND fkeyid = OBJECT_ID(N'[dbo].[coldboxreader_feed_tags]'))
ALTER TABLE [dbo].[coldboxreader_feed_tags]  WITH CHECK ADD  CONSTRAINT [FK_coldboxreader_feed_tags_coldboxreader_feed] FOREIGN KEY([feedID])
REFERENCES [dbo].[coldboxreader_feed] ([FeedID])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[coldboxreader_feed_tags] CHECK CONSTRAINT [FK_coldboxreader_feed_tags_coldboxreader_feed]


