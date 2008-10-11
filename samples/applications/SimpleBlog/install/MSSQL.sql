-- SQL Manager 2005 Lite for SQL Server (2.7.0.6)
-- ---------------------------------------
-- Host      : ICEPICK\SQLEXPRESS
-- Database  : simpleblog
-- Version   : Microsoft SQL Server  9.00.3068.00


CREATE DATABASE [simpleblog]
COLLATE SQL_Latin1_General_CP1_CI_AS
GO

USE [simpleblog]
GO

--
-- Definition for table comments : 
--

CREATE TABLE [dbo].[comments] (
  [comment_id] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
  [entry_id] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
  [comment] text COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
  [time] datetime CONSTRAINT [DF_comment_time] DEFAULT getdate() NOT NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Definition for table entries : 
--

CREATE TABLE [dbo].[entries] (
  [entry_id] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
  [entryBody] text COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
  [author] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
  [title] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
  [time] datetime NOT NULL
)
ON [PRIMARY]
TEXTIMAGE_ON [PRIMARY]
GO

--
-- Definition for table users : 
--

CREATE TABLE [dbo].[users] (
  [user_id] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
  [firstName] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
  [lastName] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
  [userName] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
  [password] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
  [lastLogin] datetime NULL,
  [userType] varchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
)
ON [PRIMARY]
GO

--
-- Data for table comments  (LIMIT 0,500)
--

INSERT INTO [dbo].[comments] ([comment_id], [entry_id], [comment], [time])
VALUES 
  ('8AAF7985-1EC9-46DA-21581A8BA613645C', '4E20F12B-1EC9-46DA-21EBE5CD8D8FA931', 'test', '20080922 08:31:07.767')
GO

INSERT INTO [dbo].[comments] ([comment_id], [entry_id], [comment], [time])
VALUES 
  ('96453491-1EC9-46DA-21EB22C9A53861EC', '4E20F12B-1EC9-46DA-21EBE5CD8D8FA931', 'test', '20080924 14:30:29.670')
GO

INSERT INTO [dbo].[comments] ([comment_id], [entry_id], [comment], [time])
VALUES 
  ('DD1022ED-1EC9-46DA-214827AD8EBF95A7', '4E20F12B-1EC9-46DA-21EBE5CD8D8FA931', 'test', '20081008 08:25:34.083')
GO

--
-- 3 record(s) inserted to [dbo].[comments]
--



--
-- Data for table entries  (LIMIT 0,500)
--

INSERT INTO [dbo].[entries] ([entry_id], [entryBody], [author], [title], [time])
VALUES 
  ('2F94E549-1EC9-46DA-21A75A540728F501', '<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.</p>
<p>Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. &nbsp;</p>', 'Henrik', 'Testing Coldspring', '20080904 15:56:39.240')
GO

INSERT INTO [dbo].[entries] ([entry_id], [entryBody], [author], [title], [time])
VALUES 
  ('2FE9F693-1EC9-46DA-21B30B4E7E1EEF65', '<p>I can see the benefit of using it now. It''s a lot easier to manage all your dependencies in a single spot. It makes it easier to properly encapsulate your variables.</p>
<p>Let''s add some more text to this post:</p>
<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.</p>
<p>Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.&nbsp;</p>', 'Henrik Joreteg', 'I Got ColdSpring Working!', '20080904 17:29:34.227')
GO

INSERT INTO [dbo].[entries] ([entry_id], [entryBody], [author], [title], [time])
VALUES 
  ('4E0DCC23-1EC9-46DA-21DFC2AE547C4C7A', '<p>&nbsp;test</p>', 'test', 'test', '20080910 13:57:19.060')
GO

INSERT INTO [dbo].[entries] ([entry_id], [entryBody], [author], [title], [time])
VALUES 
  ('4E0F56F5-1EC9-46DA-211AEE733CDA9785', '<p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.</p>
<p>&nbsp;</p>
<p>Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. &nbsp;</p>', 'Henrik', 'Some Ipsum Text', '20080910 13:59:00.197')
GO

INSERT INTO [dbo].[entries] ([entry_id], [entryBody], [author], [title], [time])
VALUES 
  ('4E20F12B-1EC9-46DA-21EBE5CD8D8FA931', '<p>&nbsp;tests</p>', 'tsets', 'test', '20080910 14:18:13.787')
GO

--
-- 5 record(s) inserted to [dbo].[entries]
--



--
-- Data for table users  (LIMIT 0,500)
--

INSERT INTO [dbo].[users] ([user_id], [firstName], [lastName], [userName], [password], [lastLogin], [userType])
VALUES 
  ('123', 'Admin', 'Admin', 'admin', 'admin', NULL, 'admin')
GO

--
-- 1 record(s) inserted to [dbo].[users]
--



--
-- Definition for indices : 
--

ALTER TABLE [dbo].[entries]
ADD CONSTRAINT [PK_post] 
PRIMARY KEY CLUSTERED ([entry_id])
WITH (
  PAD_INDEX = OFF,
  IGNORE_DUP_KEY = OFF,
  STATISTICS_NORECOMPUTE = OFF,
  ALLOW_ROW_LOCKS = ON,
  ALLOW_PAGE_LOCKS = ON)
ON [PRIMARY]
GO
