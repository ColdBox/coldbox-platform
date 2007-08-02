DROP TABLE appuser;

create table "public"."appuser" (   "appuserid" char(35) not null , "username" varchar(30) not null , "password" char(32) not null , "firstname" varchar(50) not null , "lastname" varchar(50) not null , "email" varchar(250) not null , "updatedon" timestamp , "createdon" timestamp not null default now() , "isactive" bool default false , primary key("appuserid")) 
 WITHOUT OIDS;
ALTER table "public"."appuser" SET WITHOUT CLUSTER;;

insert into "public"."appuser" values('E0DC3A63-E37C-4BDC-9B8C314C0982E203','admin','21232F297A57A5A743894A0E4A801FC3','Administrator','Postgre','admin@admin.com','2007-08-01 14:01:59.956','1999-01-01 00:00:01.000','t');
