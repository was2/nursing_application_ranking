-- This view returns the list of courses to be considered for calculating
-- gpas used in ranking nursing school applicants; the 1st component
-- eliminates duplicates that may be in v_nurse_all_courses by picking the
-- 'best' one: the highest # quality points, the the most recent term if there
-- is still a duplicate, then prefer institutional over transcript as a final
-- tiebreaker.
-- The second and third components implement manual inclusion and exclusion
-- so users can deal with special cases (a transfer course in the system should
-- be excluded because it is too old, but term_eff does not reflect its
-- actual age, for example). First manually included courses are added to the 
-- set, then manually excluded courses are subtracted.

-- CREATE OR REPLACE FORCE VIEW "MGCCOP"."V_NURSE_GPA" ("PIDM", "TERM", "CRN", "TRIT_SEQ", "TRAM_SEQ", "TRCE_SEQ", "SUBJ", "CNUM", "QPS", "HOURS", "GRADE", "SUBJ_EQIV", "CNUM_EQIV", "EXPIRED", "SRC") AS 
        
select all_courses.* --all_courses.pidm, all_courses.subj, all_courses.cnum, all_courses.subj_eqiv, all_courses.cnum_eqiv,
       --all_courses.qps, all_courses.hours, all_courses.grade, all_courses.term, all_courses.src

from MGCCOP.v_nurse_all_courses all_courses,
     ( select pidm, subj_eqiv, cnum_eqiv, 
              max( to_number(qps||term||decode(src, 'tran', '0', 'inst', '1')) ) uniqifier
         from MGCCOP.v_nurse_all_courses
        where expired is null or expired = 'N'
        group by pidm, subj_eqiv, cnum_eqiv ) bestest_courses

where bestest_courses.pidm = all_courses.pidm
  and bestest_courses.subj_eqiv = all_courses.subj_eqiv
  and bestest_courses.cnum_eqiv = all_courses.cnum_eqiv
  and bestest_courses.uniqifier = to_number ( all_courses.qps ||
                                    all_courses.term ||
                                    decode(all_courses.src, 'tran', '0', 'inst', '1') )
-----                                    
union
-----

select all_courses.* --all_courses.pidm, all_courses.subj, all_courses.cnum, all_courses.subj_eqiv, all_courses.cnum_eqiv,
       --all_courses.qps, all_courses.hours, all_courses.grade, all_courses.term, all_courses.src
 
  from mgccop.v_nurse_all_courses all_courses,
       mgccop.nurse_course_inc_exc manual_courses
  
 where all_courses.pidm = manual_courses.pidm
   and all_courses.term = manual_courses.term
   and manual_courses.indicator = 'I'
   and ( ('SHRTCKN' = upper(src_table) and all_courses.crn = manual_courses.crn)
         or ('SHRTRCE' = upper(src_table) 
              and all_courses.trit_seq = manual_courses.trit_seq
              and all_courses.tram_seq = manual_courses.tram_seq
              and all_courses.trce_seq = manual_courses.trce_seq
            )
       )
       
-----                                    
minus
-----

select all_courses.* --all_courses.pidm, all_courses.subj, all_courses.cnum, all_courses.subj_eqiv, all_courses.cnum_eqiv,
       --all_courses.qps, all_courses.hours, all_courses.grade, all_courses.term, all_courses.src
 
  from mgccop.v_nurse_all_courses all_courses,
       mgccop.nurse_course_inc_exc manual_courses
  
 where all_courses.pidm = manual_courses.pidm
   and all_courses.term = manual_courses.term
   and manual_courses.indicator = 'E'
   and ( ('SHRTCKN' = upper(src_table) and all_courses.crn = manual_courses.crn)
         or ('SHRTRCE' = upper(src_table) 
              and all_courses.trit_seq = manual_courses.trit_seq
              and all_courses.tram_seq = manual_courses.tram_seq
              and all_courses.trce_seq = manual_courses.trce_seq
            )
       )