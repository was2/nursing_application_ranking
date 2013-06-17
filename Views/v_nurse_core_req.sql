-- CREATE OR REPLACE FORCE VIEW "MGCCOP"."V_NURSE_CORE_REQ" ("PIDM", "SUBJ", "CNUM", "QPS", "HOURS", "GRADE", "TERM", "SRC") AS 
        
select all_courses.pidm, all_courses.subj, all_courses.cnum, all_courses.qps, 
       all_courses.hours, all_courses.grade, all_courses.term, all_courses.src
        
from MGCCOP.v_nurse_all_courses all_courses,
     ( select pidm, subj, cnum, 
              max(qps||term||decode(src, 'tran', '0', 'inst', '1') ) uniqifier
         from MGCCOP.v_nurse_all_courses
        group by pidm, subj, cnum ) bestest_courses

where bestest_courses.pidm = all_courses.pidm
  and bestest_courses.subj = all_courses.subj
  and bestest_courses.cnum = all_courses.cnum
  and bestest_courses.uniqifier = (all_courses.qps ||
                                   all_courses. term ||
                                   decode(all_courses.src, 'tran', '0', 'inst', '1') )

-- only get core req. for nursing application         
and ( subj_eqiv, cnum_eqiv ) in ( ('ENG', '1113'), ('BIO', '2514'),
                                  ('BIO', '2924'), ('PSY', '1513') )
                        
order by pidm, subj, cnum