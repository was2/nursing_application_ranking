--CREATE OR REPLACE FORCE VIEW "MGCCOP"."V_NURSE_TEST" ("PIDM", "ACT_MATH", "ACT_READ", "ACT_COMP", "TEAS") AS 
  select 
    applicants.pidm, 
    act_math.score act_math, act_read.score act_read, act_comp.score act_comp,
    teas.score teas
from
    ( select pidm 
      from mgccop.nurse_applicants ) applicants,
      
    ( select sortest_pidm pidm, max (sortest_test_score) score
      from sortest 
      where sortest_tesc_code = 'A02'
      group by sortest_pidm ) act_math,
      
    ( select sortest_pidm pidm, max (sortest_test_score) score
      from sortest 
      where sortest_tesc_code = 'A03'
      group by sortest_pidm ) act_read,

    ( select sortest_pidm pidm, max (sortest_test_score) score
      from sortest 
      where sortest_tesc_code = 'A05'
      group by sortest_pidm ) act_comp,

    ( select sortest_pidm pidm, max (sortest_test_score) score
      from sortest
      where sortest_tesc_code = 'TEC'
      group by sortest_pidm ) teas
where
    applicants.pidm = act_math.pidm (+) and
    applicants.pidm = act_read.pidm (+) and
    applicants.pidm = act_comp.pidm (+) and
    applicants.pidm = teas.pidm (+);