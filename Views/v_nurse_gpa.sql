--CREATE OR REPLACE FORCE VIEW "MGCCOP"."V_NURSE_GPA" ("PIDM", "QPS", "HOURS") AS 

select all_courses.pidm, sum(all_courses.qps) qps, sum(all_courses.hours) hours
        
from MGCCOP.v_nurse_all_courses all_courses,
     ( select pidm, subj, cnum, 
              max(qps||term||decode(src, 'tran', '0', 'inst', '1') ) uniqifier
         from MGCCOP.v_nurse_all_courses
        group by pidm, subj, cnum ) bestest_courses

where bestest_courses.pidm = all_courses.pidm
  and bestest_courses.subj = all_courses.subj
  and bestest_courses.cnum = all_courses.cnum
  and bestest_courses.uniqifier = ( all_courses.qps ||
                                    all_courses.term ||
                                    decode(all_courses.src, 'tran', '0', 'inst', '1') )

group by all_courses.pidm