-- CREATE OR REPLACE FORCE VIEW "MGCCOP"."V_NURSE_COURSE_EQIV" ("SUBJ_REQ", "CNUM_REQ", "SUBJ_EQIV", "CNUM_EQIV") AS 

select screqiv_subj_code subj_req, screqiv_crse_numb cnum_req,
       screqiv_subj_code_eqiv subj_eqiv, screqiv_crse_numb_eqiv cnum_eqiv
  from screqiv
 where (screqiv_subj_code, screqiv_crse_numb) in
       ( select subj, cnum from mgccop.nurse_eligible_courses )
-----
union
-----

select screqiv_subj_code_eqiv, screqiv_crse_numb_eqiv,
       screqiv_subj_code, screqiv_crse_numb
from screqiv
where (screqiv_subj_code_eqiv, screqiv_crse_numb_eqiv) in
       ( select subj, cnum from mgccop.nurse_eligible_courses )

-----
union
-----

select subj, cnum, subj, cnum from mgccop.nurse_eligible_courses