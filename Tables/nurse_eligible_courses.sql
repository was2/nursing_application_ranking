drop table mgccop.nurse_eligible_courses;

CREATE TABLE "MGCCOP"."NURSE_ELIGIBLE_COURSES" 
 (	"SUBJ" VARCHAR2(20 BYTE), 
"CNUM" VARCHAR2(20 BYTE), 
"CORE_REQ" CHAR(1 CHAR), 
"MAX_AGE" NUMBER(*,0) DEFAULT null
 ) SEGMENT CREATION IMMEDIATE 
PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
NOCOMPRESS LOGGING
STORAGE(INITIAL 131072 NEXT 131072 MINEXTENTS 1 MAXEXTENTS 2147483645
PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
TABLESPACE "MGCCC" ;

 COMMENT ON COLUMN "MGCCOP"."NURSE_ELIGIBLE_COURSES"."CORE_REQ" IS 'is the course in question a core requirement for consideration in the ranking?';
 COMMENT ON COLUMN "MGCCOP"."NURSE_ELIGIBLE_COURSES"."MAX_AGE" IS 'The maximum age, in months, a course may be to be included in the applicants gpa calculation';

insert into mgccop.nurse_eligible_courses (select 'ENG', '1113', 'Y', null from dual);
insert into mgccop.nurse_eligible_courses (select 'ENG', '1123', 'N', null from dual);
insert into mgccop.nurse_eligible_courses (select 'BIO', '2514', 'Y', 60   from dual);
insert into mgccop.nurse_eligible_courses (select 'BIO', '2924', 'Y', 60   from dual);
insert into mgccop.nurse_eligible_courses (select 'PSY', '1513', 'Y', null from dual);
insert into mgccop.nurse_eligible_courses (select 'BIO', '2524', 'N', 60   from dual);
insert into mgccop.nurse_eligible_courses (select 'EPY', '2533', 'N', null from dual);
insert into mgccop.nurse_eligible_courses (select 'SOC', '2113', 'N', null from dual);
insert into mgccop.nurse_eligible_courses (select 'SPT', '1113', 'N', null from dual);

insert into mgccop.nurse_eligible_courses (
select distinct scbcrse_subj_code, scbcrse_crse_numb, 'N', '60' from scbcrse where scbcrse_subj_code = 'NUR' and scbcrse_csta_code <> 'I'
);