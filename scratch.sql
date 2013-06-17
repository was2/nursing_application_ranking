--select all_courses.pidm, all_courses.subj, all_courses.cnum, 
--              (qps||term||decode(src, 'tran', '0', 'inst', '1') ) uniqifier
--         from MGCCOP.v_nurse_all_courses all_courses--, stvterm, 
--            --  mgccop.nurse_eligible_courses ec
--          where all_courses.pidm = 125282
--       -- where term = stvterm_code
--        --  and all_courses.subj_eqiv = ec.subj
--         -- and all_courses.cnum_eqiv = ec.cnum
--          --and ( ec.max_age is null or add_months(stvterm_end_date, ec.max_age) >= sysdate )
--  
--        
--        minus

select all_courses.pidm, all_courses.subj, all_courses.cnum, 
              max(qps||term||decode(src, 'tran', '0', 'inst', '1') ) uniqifier,
              all_courses.subj_eqiv, all_courses.cnum_eqiv
         from MGCCOP.v_nurse_all_courses all_courses, stvterm,
              mgccop.nurse_eligible_courses ec
        where all_courses.pidm = 125282
          and ( 
                ( all_courses.term = stvterm_code
                  and all_courses.subj_eqiv = ec.subj
                  and all_courses.cnum_eqiv = ec.cnum
                  and ( ec.max_age is null or add_months(stvterm_end_date, ec.max_age) >= sysdate ) )  
                or all_courses.subj_eqiv = 'NUR'
              )
        group by all_courses.pidm, all_courses.subj, all_courses.cnum, all_courses.subj_eqiv, all_courses.cnum_eqiv;

select distinct ssbsect_subj_code, ssbsect_crse_numb from ssbsect where ssbsect_subj_code = 'NUR'
and  ssbsect_term_code > '200010'