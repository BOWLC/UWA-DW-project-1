USE SeekAU

/*Delete tables*/
drop table dbo.SeekRAW1
drop table FactPost
drop table DimJob
drop table DimTime
drop table DimCompany
drop table dbo.SeekStaging


BEGIN TRANSACTION
GO
CREATE TABLE dbo.SeekStaging
	(
	Category varchar(50) NULL,
	City varchar(50) NULL,
	CompanyName varchar(50) NULL,
	CompanyID int NULL,
	geo varchar(50)  NULL,
	job_board varchar(50)  NULL,
	job_description varchar(MAX)  NULL,
	job_title varchar(50)  NULL,
	jobID int NULL,
	job_type varchar(50)  NULL,
	post_date varchar(50)  NULL,
	post_day int NULL,
	post_month int NULL,
	post_year int null,
	post_time time NULL,
	dateID int NULL,
	salary_s varchar(50) NULL,
	salary_i int NULL,
	salary_ID int NULL,
	job_state varchar(50) NULL,
	url varchar(50)  NULL
	)  ON [PRIMARY]
	 TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE dbo.SeekStaging SET (LOCK_ESCALATION = TABLE)
GO
COMMIT

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.DimCompany
	(
	CompanyID int NOT NULL IDENTITY (1, 1),
	Name varchar(50) NOT NULL,
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.DimCompany ADD CONSTRAINT
	PK_DimCompany PRIMARY KEY CLUSTERED 
	(
	CompanyID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.DimCompany SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.DimJob
	(
	JobID int NOT NULL IDENTITY (1, 1),
	Category varchar(50) NOT NULL,
	Type varchar(50) NOT NULL,
	Title varchar(50) NOT NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.DimJob ADD CONSTRAINT
	PK_DimJob PRIMARY KEY CLUSTERED 
	(
	JobID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.DimJob SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.DimTime
	(
	DateID int NOT NULL IDENTITY (1, 1),
	day int NOT NULL,
	month int NOT NULL,
	year int NOT NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.DimTime ADD CONSTRAINT
	PK_DimTime PRIMARY KEY CLUSTERED 
	(
	DateID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.DimTime SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.FactPost
	(
	PostID int NOT NULL IDENTITY (1, 1),
	JobID int NOT NULL,
	CompanyID int NOT NULL,
	DateID int NOT NULL,
	URL varchar(50) NOT NULL,
	Time time(7) NOT NULL,
	Salary int NOT NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.FactPost ADD CONSTRAINT
	PK_FactPost PRIMARY KEY CLUSTERED 
	(
	PostID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.FactPost ADD CONSTRAINT
	FK_FactPost_DimTime FOREIGN KEY
	(
	DateID
	) REFERENCES dbo.DimTime
	(
	DateID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.FactPost ADD CONSTRAINT
	FK_FactPost_DimJob FOREIGN KEY
	(
	JobID
	) REFERENCES dbo.DimJob
	(
	JobID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.FactPost ADD CONSTRAINT
	FK_FactPost_DimCompany FOREIGN KEY
	(
	CompanyID
	) REFERENCES dbo.DimCompany
	(
	CompanyID
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.FactPost SET (LOCK_ESCALATION = TABLE)
GO
COMMIT


/*Create temp table to hold data while it is cleaned*/
BEGIN TRANSACTION
GO
CREATE TABLE dbo.SeekRAW1
	(
	Category varchar(50) NULL,
	City varchar(50) NULL,
	CompanyName varchar(max) NULL,
	geo varchar(50)  NULL,
	job_board varchar(50)  NULL,
	job_description varchar(max)  NULL,
	job_title varchar(max)  NULL,
	job_type varchar(50)  NULL,
	post_date varchar(50)  NULL,
	salary_offered varchar(max) NULL,
	job_state varchar(50) NULL,
	url varchar(50)  NULL
	)  ON [PRIMARY]
	 TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE dbo.SeekRAW1 SET (LOCK_ESCALATION = TABLE)
GO
COMMIT

/*import from CSV*/
BULK INSERT [dbo].[SeekRAW1] FROM 'C:\DW_Project\seek_australia.csv'
WITH (
 CHECK_CONSTRAINTS,
 --CODEPAGE='ACP',
 FORMAT='CSV',
 FIRSTROW = 2,
 DATAFILETYPE='char',
 FIELDTERMINATOR=',',
 ROWTERMINATOR='\n',
 KEEPIDENTITY,
 TABLOCK
);

/* DELETE orphan records*/
delete from dbo.SeekRAW1 where url is NULL
delete from dbo.seekRAW1 where job_title is NULL
delete from dbo.seekRAW1 where post_date is NULL

/*Delete junk characters*/


UPDATE dbo.SeekRAW1
SET job_description = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(job_description, 'Ã', ''), '+é-á', ''), '¢', 'Â'), '€', ''), 'Â', ''), '¦', ''), ']', ''), '[', ''), '+óGé¼G', ''), '£', ''), 'ó', ''), 'é',''), '+G¼-', ''),'Ç',''),'"','')


UPDATE dbo.SeekRAW1
SET job_title =  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(job_title, 'Ã', ''), '+é-á', ''), '¢', 'Â'), '€', ''), 'Â', ''), '¦', ''), ']', ''), '[', ''), '+óGé¼G', ''), '£', ''), 'ó', ''), 'é',''), '+G¼-', ''),'Ç',''),'"','')
UPDATE dbo.SeekRAW1
SET CompanyName = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CompanyName, 'Ã', ''), '+é-á', ''), '¢', 'Â'), '€', ''), 'Â', ''), '¦', ''), ']', ''), '[', ''), '+óGé¼G', ''), '£', ''), 'ó', ''), 'é',''), '+G¼-', ''),'Ç',''),'"','')
UPDATE dbo.SeekRAW1
SET Category = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Category, 'Ã', ''), '+é-á', ''), '¢', 'Â'), '€', ''), 'Â', ''), '¦', ''), ']', ''), '[', ''), '+óGé¼G', ''), '£', ''), 'ó', ''), 'é',''), '+G¼-', ''),'Ç',''),'"','')
UPDATE dbo.SeekRAW1
SET City = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(City, 'Ã', ''), '+é-á', ''), '¢', 'Â'), '€', ''), 'Â', ''), '¦', ''), ']', ''), '[', ''), '+óGé¼G', ''), '£', ''), 'ó', ''), 'é',''), '+G¼-', ''),'Ç',''),'"','')
UPDATE dbo.SeekRAW1
SET Geo = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(Geo, 'Ã', ''), '+é-á', ''), '¢', 'Â'), '€', ''), 'Â', ''), '¦', ''), ']', ''), '[', ''), '+óGé¼G', ''), '£', ''), 'ó', ''), 'é',''), '+G¼-', ''),'Ç',''),'"','')
UPDATE dbo.SeekRAW1
SET job_board = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(job_board, 'Ã', ''), '+é-á', ''), '¢', 'Â'), '€', ''), 'Â', ''), '¦', ''), ']', ''), '[', ''), '+óGé¼G', ''), '£', ''), 'ó', ''), 'é',''), '+G¼-', ''),'Ç',''),'"','')
UPDATE dbo.SeekRAW1
SET salary_offered = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(salary_offered, 'Ã', ''), '+é-á', ''), '¢', 'Â'), '€', ''), 'Â', ''), '¦', ''), ']', ''), '[', ''), '+óGé¼G', ''), '£', ''), 'ó', ''), 'é',''), '+G¼-', ''),'Ç',''),'"','')
UPDATE dbo.SeekRAW1
SET job_state = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(job_state, 'Ã', ''), '+é-á', ''), '¢', 'Â'), '€', ''), 'Â', ''), '¦', ''), ']', ''), '[', ''), '+óGé¼G', ''), '£', ''), 'ó', ''), 'é',''), '+G¼-', ''),'Ç',''),'"','')
UPDATE dbo.SeekRAW1
SET url = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(url, 'Ã', ''), '+é-á', ''), '¢', 'Â'), '€', ''), 'Â', ''), '¦', ''), ']', ''), '[', ''), '+óGé¼G', ''), '£', ''), 'ó', ''), 'é',''), '+G¼-', ''),'Ç',''),'"','')


/*remove text only entries or no salary info (no '$')*/
UPDATE dbo.SeekRAW1
SET salary_offered = '0'
where salary_offered not like '%[0-9]%'
	or salary_offered is null
	or salary_offered not like '%$%'

/*Normalise salary data*/
UPDATE dbo.SeekRAW1
SET  salary_offered = REPLACE(REPLACE(REPLACE(SUBSTRING(salary_offered,CHARINDEX('$',salary_offered), len(salary_offered)-CHARINDEX('$',salary_offered)+1),',',''),'$',''),'K','000')
where salary_offered like '%per Year%'
	 or salary_offered like '%yr %'
	 or salary_offered like '%py %'
	 or salary_offered like '%p.y%'
	 or salary_offered like '%p/y  %'
	 or salary_offered like '%/y %'
	 or salary_offered like '%annual%'
	 or salary_offered like '%/a %'
	 or salary_offered like '%/pa %'
	 or salary_offered like '%p/a %'
	 or salary_offered like '%p.a%'
	 or salary_offered like '%annum%'
	 or salary_offered like '%/year %'
	 or salary_offered like '%/ year %'
	 or salary_offered like '%package%'
	 or salary_offered like '%Package%'

UPDATE dbo.SeekRAW1
SET  salary_offered = SUBSTRING(salary_offered,1, PATINDEX('%[^0-9]%', salary_offered)-1)
where salary_offered like '%per Year%'
	 or salary_offered like '%yr %'
	 or salary_offered like '%py %'
	 or salary_offered like '%p.y%'
	 or salary_offered like '%p/y  %'
	 or salary_offered like '%/y %'
	 or salary_offered like '%annual%'
	 or salary_offered like '%/a %'
	 or salary_offered like '%/pa %'
	 or salary_offered like '%p/a %'
	 or salary_offered like '%p.a%'
	 or salary_offered like '%annum%'
	 or salary_offered like '%/year %'
	 or salary_offered like '%/ year %'
	 or salary_offered like '%package%'
	 or salary_offered like '%Package%'

UPDATE dbo.SeekRAW1
SET  salary_offered = REPLACE(REPLACE(REPLACE(SUBSTRING(salary_offered,CHARINDEX('$',salary_offered), len(salary_offered)-CHARINDEX('$',salary_offered)+1),',',''),'$',''),'K','000')
where salary_offered like '%per month%'
	 or salary_offered like '%mn %'
	 or salary_offered like '%pm %'
	 or salary_offered like '%p.m%'
	 or salary_offered like '%/month %'
	 or salary_offered like '%/ month %'

UPDATE dbo.SeekRAW1
SET  salary_offered = 12*CAST(SUBSTRING(salary_offered,1, PATINDEX('%[^0-9]%', salary_offered)-1) as int)
where salary_offered like '%per month%'
	 or salary_offered like '%mn %'
	 or salary_offered like '%pm %'
	 or salary_offered like '%p.m%'
	 or salary_offered like '%p/m %'
	 or salary_offered like '%/m %'
	 or salary_offered like '%/month %'
	 or salary_offered like '%/ month %'

UPDATE dbo.SeekRAW1
SET  salary_offered = REPLACE(REPLACE(REPLACE(SUBSTRING(salary_offered,CHARINDEX('$',salary_offered), len(salary_offered)-CHARINDEX('$',salary_offered)+1),',',''),'$',''),'K','000')
where salary_offered like '%per fortnight%'
	 or salary_offered like '%pf %'
	 or salary_offered like '%p.f%'
	 or salary_offered like '%p/f %'
	 or salary_offered like '%/fortnight %'
	 or salary_offered like '%/ fortnight %'

UPDATE dbo.SeekRAW1
SET  salary_offered = 26*CAST(SUBSTRING(salary_offered,1, PATINDEX('%[^0-9]%', salary_offered)-1) as int)
where salary_offered like '%per fortnight%'
	 or salary_offered like '%pf %'
	 or salary_offered like '%p.f%'
	 or salary_offered like '%p/f %'
	 or salary_offered like '%/fortnight %'
	 or salary_offered like '%/ fortnight %'

UPDATE dbo.SeekRAW1
SET  salary_offered = REPLACE(REPLACE(REPLACE(SUBSTRING(salary_offered,CHARINDEX('$',salary_offered), len(salary_offered)-CHARINDEX('$',salary_offered)+1),',',''),'$',''),'K','000')
where salary_offered like '%per week%'
	 or salary_offered like '%wk %'
	 or salary_offered like '%pw  %'
	 or salary_offered like '%p.w%'
	 or salary_offered like '%p/w %'
	 or salary_offered like '%/w %'
	 or salary_offered like '%/week%'
	 or salary_offered like '%/ week%'

UPDATE dbo.SeekRAW1
SET  salary_offered = 52*CAST(SUBSTRING(salary_offered,1, PATINDEX('%[^0-9]%', salary_offered)-1) as int)
where salary_offered like '%per week%'
	 or salary_offered like '%wk %'
	 or salary_offered like '%pw %'
	 or salary_offered like '%p.w%'
	 or salary_offered like '%p/w %'
	 or salary_offered like '%/w %'
	 or salary_offered like '%/week%'
	 or salary_offered like '%/ week%'

UPDATE dbo.SeekRAW1
SET  salary_offered = REPLACE(REPLACE(REPLACE(SUBSTRING(salary_offered,CHARINDEX('$',salary_offered), len(salary_offered)-CHARINDEX('$',salary_offered)+1),',',''),'$',''),'K','000')
where salary_offered like '%per day%'
	 or salary_offered like '%pd %'
	 or salary_offered like '%p.d%'
	 or salary_offered like '%p/d%'
	 or salary_offered like '%/ day%'

	 /*per day assumed working 5 days per week*/
UPDATE dbo.SeekRAW1
SET  salary_offered = 52*5*CAST(SUBSTRING(salary_offered,1, PATINDEX('%[^0-9]%', salary_offered)-1) as int)
where salary_offered like '%per day%'
	 or salary_offered like '%pd %'
	 or salary_offered like '%p.d%'
	 or salary_offered like '%p/d%'
	 or salary_offered like '%/ day%'


UPDATE dbo.SeekRAW1
SET  salary_offered = REPLACE(REPLACE(REPLACE(SUBSTRING(salary_offered,CHARINDEX('$',salary_offered), len(salary_offered)-CHARINDEX('$',salary_offered)+1),',',''),'$',''),'K','000')
where salary_offered like '%hr %'
	 or salary_offered like '%ph %'
	 or salary_offered like '%p.h%'
	 or salary_offered like '%p/h %'
	 or salary_offered like '%per hour%'

UPDATE dbo.SeekRAW1
SET  salary_offered = 52*38*CAST(SUBSTRING(salary_offered,1, PATINDEX('%[^0-9]%', salary_offered)-1) as int)
where salary_offered like '%hr %'
	 or salary_offered like '%ph %'
	 or salary_offered like '%p.h%'
	 or salary_offered like '%p/h %'
	 or salary_offered like '%per hour%'




UPDATE dbo.SeekRAW1
SET  job_title = (REPLACE(REPLACE(REPLACE(REPLACE(job_title,'Part Time',''),'Full Time',''),'Part-Time',''),'Experienced',''))


UPDATE dbo.SeekRAW1
SET  job_title =  TRIM('-!.* ' FROM job_title)

UPDATE dbo.SeekRAW1
SET  job_title = SUBSTRING(job_title,1, CHARINDEX('-',job_title)-1)
	where job_title like '%-%'
	AND job_title not like '%[a-z]-%'





/*delete left of first '$'*/
UPDATE dbo.SeekRAW1
SET salary_offered = SUBSTRING(salary_offered,CHARINDEX('$',salary_offered), len(salary_offered)-CHARINDEX('$',salary_offered)+1)

/*replace 'k' with '000'*/
UPDATE dbo.SeekRAW1
SET  salary_offered = REPLACE(REPLACE(salary_offered,',',''),'$','')

/*Delete past first number*/
UPDATE dbo.SeekRAW1
SET salary_offered  = SUBSTRING(salary_offered,1, PATINDEX('%[^0-9]%', salary_offered)-1)
where salary_offered like '%[0-9][^0-9]%'

UPDATE dbo.SeekRAW1
SET  salary_offered = 0
where salary_offered like '%[^0-9]%'

/*assume remaining small numbers (<10000) are in case of $xx-$xxk*/
UPDATE dbo.SeekRAW1
SET  salary_offered = CONCAT(salary_offered,'000')
where (salary_offered < 500 AND salary_offered != 0)

UPDATE dbo.SeekRAW1
SET Category = 'unknown'
where Category is null

UPDATE dbo.SeekRAW1
SET City = 'unknown'
where City is null

UPDATE dbo.SeekRAW1
SET CompanyName = 'unknown'
where CompanyName is null

UPDATE dbo.SeekRAW1
SET job_state = 'unknown'
where job_state is null

UPDATE dbo.SeekRAW1
SET job_description = 'no description'
where job_description is null

UPDATE dbo.SeekRAW1
SET job_title = 'no title'
where job_title is null


UPDATE dbo.SeekRAW1
SET Category = SUBSTRING(Category,1,50)

UPDATE dbo.SeekRAW1
SET City = SUBSTRING(City,1,50)

UPDATE dbo.SeekRAW1
SET CompanyName = SUBSTRING(CompanyName,1,50)

UPDATE dbo.SeekRAW1
SET geo = SUBSTRING(geo,1,50)

UPDATE dbo.SeekRAW1
SET job_board = SUBSTRING(job_board,1,50)

UPDATE dbo.SeekRAW1
SET job_state = SUBSTRING(job_state,1,50)

UPDATE dbo.SeekRAW1
SET job_title = SUBSTRING(job_title,1,50)



Select * from SeekRAW1
