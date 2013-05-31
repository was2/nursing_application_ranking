--pulls all courses w/in proper time frame used for
--consideration in nursing applicaions. Does not
--find maximum grades for an indivdual course, this
--is done via sub-views, see v_nurse_gpa

--current issues:
--split-lab courses from transcript only pull in the max qps of class or lab, not both
--transcript courses do not have useful term info, cant determine if courses are too old


-- CREATE OR REPLACE FORCE VIEW "MGCCOP"."V_NURSE_ALL_COURSES" ("PIDM", "TERM", "SUBJ", "CNUM", "QPS", "HOURS", "GRADE", "SUBJ_EQIV", "CNUM_EQIV", "SRC") AS 
select
     shrtckn_pidm pidm, shrtckn_term_code term, 
     shrtckn_subj_code subj, shrtckn_crse_numb cnum,
     shrgrde_quality_points * shrtckg_credit_hours qps,
     shrtckg_credit_hours hours, shrtckg_grde_code_final,
     nvl(subj_req, shrtckn_subj_code) subj_req, nvl(cnum_req, shrtckn_crse_numb) cnum_req,
     'inst' as src

from shrtckn, shrtckg, shrgrde, mgccop.nurse_applicants applicants,
     MGCCOP.v_nurse_course_eqiv eqivs, stvterm,
     ( select shrtckg_pidm pidm, shrtckg_term_code tc, shrtckg_tckn_seq_no tckn_seq, max(shrtckg_seq_no) seq
       from shrtckg, mgccop.nurse_applicants
       where shrtckg_pidm = nurse_applicants.pidm
       group by shrtckg_pidm, shrtckg_term_code, shrtckg_tckn_seq_no ) max_g

where
      shrtckn_pidm = applicants.pidm
      -- and applicants.term = '201330'
      
      -- join to stvterm for course age restriction
      and stvterm_code = shrtckn_term_code
      
      -- join to shrtckg
      and shrtckg_pidm = shrtckn_pidm
      and shrtckg_term_code = shrtckn_term_code
      and shrtckg_tckn_seq_no =  shrtckn_seq_no
      
      -- then filter out all but the max seq. no. in shrtckg w/inline view max_g
      and max_g.pidm = shrtckg_pidm
      and max_g.tc = shrtckg_term_code
      and max_g.tckn_seq = shrtckg_tckn_seq_no
      and max_g.seq = shrtckg_seq_no

      -- filter out grade codes that do not indicate passing
      and shrgrde.shrgrde_code = shrtckg_grde_code_final
      and shrgrde.shrgrde_passed_ind = 'Y'

      -- filter out courses excluded due to repeats
      and ( (shrtckn_repeat_course_ind = 'I') or
            (shrtckn_repeat_course_ind is null) ) 

      -- deal w/equivelent courses using the equiv view
      and shrtckn_subj_code = subj_eqiv (+)
      and shrtckn_crse_numb = cnum_eqiv (+)

      and (
            ( shrtckn_subj_code, shrtckn_crse_numb ) in
              ( select subj, cnum from mgccop.nurse_eligible_courses
                                 where max_age is null )

            -- these courses must not be older than max_age months
            or ( ( shrtckn_subj_code, shrtckn_crse_numb ) in
                 ( select subj, cnum from mgccop.nurse_eligible_courses
                                 where max_age is not null
                                -- and add_months(stvterm_end_date, max_age) >= sysdate
                 )
               )
               
            or ( shrtckn_subj_code, shrtckn_crse_numb ) in
                 ( select subj_eqiv, cnum_eqiv 
                     from mgccop.v_nurse_course_eqiv
                    where ( subj_req, cnum_req ) in 
                          ( select subj, cnum from mgccop.nurse_eligible_courses
                                              where max_age is null ) )
  
            or ( ( shrtckn_subj_code, shrtckn_crse_numb ) in
                  ( select subj_eqiv, cnum_eqiv 
                       from mgccop.v_nurse_course_eqiv
                      where ( subj_req, cnum_req ) in 
                            ( select subj, cnum from mgccop.nurse_eligible_courses
                                 where max_age is not null
                                 --and add_months(stvterm_end_date, max_age) >= sysdate
                            )
                  )
               )
            
            or ( shrtckn_subj_code = 'NUR'
                 --and add_months(stvterm_end_date, 60) >= sysdate
               )
           )

union all

select
       shrtrce_pidm pidm, shrtrce_term_code_eff,
       shrtrce_subj_code subj, shrtrce_crse_numb cnum, 
       shrgrde.shrgrde_quality_points * shrtrce.shrtrce_credit_hours,
       shrtrce_credit_hours, shrtrce_grde_code,
       nvl(subj_req, shrtrce_subj_code) subj_req, nvl(cnum_req, shrtrce_crse_numb) cnum_req, 
       'tran' as src

from shrtrce, shrgrde, mgccop.nurse_applicants applicants,
     MGCCOP.v_nurse_course_eqiv eqivs

where
      shrtrce_pidm = applicants.pidm
      
      and shrgrde.shrgrde_code = shrtrce_grde_code

      and shrgrde.shrgrde_passed_ind = 'Y'
  

      and ( (shrtrce_repeat_course = 'I') or
            (shrtrce_repeat_course is null) )
      
      and shrtrce_subj_code = subj_eqiv (+)
      and shrtrce_crse_numb = cnum_eqiv (+)

      and (
            ( shrtrce_subj_code, shrtrce_crse_numb ) in
              ( select subj, cnum from mgccop.nurse_eligible_courses
                                 where max_age is null )

            -- these courses must not be older than 5 yrs
            or ( ( shrtrce_subj_code, shrtrce_crse_numb ) in
                 ( select subj, cnum from mgccop.nurse_eligible_courses
                                 where max_age is not null
                                 --and add_months(stvterm_end_date, max_age) >= sysdate
                 )
               )
               
            or ( shrtrce_subj_code, shrtrce_crse_numb ) in
                 ( select subj_eqiv, cnum_eqiv 
                     from mgccop.v_nurse_course_eqiv
                    where ( subj_req, cnum_req ) in 
                          ( select subj, cnum from mgccop.nurse_eligible_courses
                                              where max_age is null ) )
  
            or ( ( shrtrce_subj_code, shrtrce_crse_numb ) in
                  ( select subj_eqiv, cnum_eqiv 
                       from mgccop.v_nurse_course_eqiv
                      where ( subj_req, cnum_req ) in 
                            ( select subj, cnum from mgccop.nurse_eligible_courses
                                 where max_age is not null
                                 --and add_months(stvterm_end_date, max_age) >= sysdate
                            )
                  )
               )
            
            or ( shrtrce_subj_code = 'NUR'
               --and add_months(stvterm_end_date, 60) >= sysdate 
               )
           )
 
order by pidm, src, subj, cnum;
