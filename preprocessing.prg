
import "C:\Users\Michael Ryan\Desktop\RQ1\Macro_data1.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @id @date(date) @smpl @all

inflation.hpf(lambda=1600) inflation_hp @ inflation_cycle

NOM_IR_10YR.hpf(lambda=1600) NOM_IR_10YR_hp @ ir_cycle

BIS_REER.hpf(lambda=1600) BIS_REER_hp @ BIS_REER_cycle

nzl_u.hpf(lambda=1600) nzl_u_hp @ nzl_u_cycle

series ub=@mean(nzl_u_cycle)+1.65*@stdev(nzl_u_cycle)

series bloomiv=@recode(nzl_u_cycle>ub,1,0)

'this is the exo_events file renmamed
import "C:\Users\Michael Ryan\Desktop\rq2\Narrative_IV.csv" ftype=ascii rectype=crlf skip=0 fieldtype=delimited delim=comma colhead=1 eoltype=pad badfield=NA @freq Q @id @date(date_q) @destid @date @smpl @all

'estimate the recursive SVAR and save manually
smpl 1985Q2 2017Q4
series policy_u=policy_shock_f
series ir=ir_cycle
series rer=BIS_REER_cycle
series inflation=inflation_cycle

var rvar.ls 1 4 nzl_u stock nz_ygap inflation ir rer
rvar.results
rvar.impulse(35, t, se=a, matbys=eviews_ir) @imp nzl_u

rvar.makeresids(imp=chol) ss1 ss2 ss3 ss4 ss5 ss6
''''''Instrument relevance tests  (table 2)
rvar.ls 1 4 nzl_u stock nz_ygap inflation ir rer
rvar.resids
rvar.makeresids
series et_u=RESID01

'Montiel stock and watson (see kanzig 2019 oil supply news)
equation msw.ls(cov=white) et_u c policy_u

'Lunsford test  (use hac as DW LB critical stat  1.69 (n=127 and k=2)
equation lun.ls(cov=hac) policy_u c et_u 

''''''''instrument exogeneity tests  (table 3 of paper)



' use white se
equation wexosm.ls(cov=white) ss2 c policy_u 
equation wexoygap.ls(cov=white) ss3 c policy_u 
equation wexoinf.ls(cov=white) ss4 c policy_u 
equation wexoir.ls(cov=white) ss5 c policy_u 
equation wexorer.ls(cov=white) ss6 c policy_u


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'check bloom iv 



'Montiel stock and watson (see kanzig 2019 oil supply news)
equation bloom_msw.ls(cov=white) et_u c bloomiv

'Lunsford test (use hac as DW LB critical stat  1.69 (n=127 and k=2; k includes intercept in table im using)
equation bloom_lun.ls(cov=hac) bloomiv c et_u

''''''''instrument exogeneity tests  (table 3 of paper)
'import "C:\Users\Michael Ryan\Desktop\rq2\structuralshocks_recursive_updated.xlsx" range=Sheet1 colhead=1 na="#N/A" @freq Q 1986Q2 @smpl @all



'use white se
equation bloom_wexosm.ls(cov=white) ss2 c bloomiv
equation bloom_wexoygap.ls(cov=white) ss3 c bloomiv 
equation bloom_wexoinf.ls(cov=white) ss4 c bloomiv
equation bloom_wexoir.ls(cov=white) ss5 c bloomiv
equation bloom_wexorer.ls(cov=white) ss6 c bloomiv

''''''''''

cd "C:\Users\Michael Ryan\Desktop\rq2\"
'wfsave(mode=update, noid) data_for_SVARIV.xlsx @smpl 1985Q2 2017Q4  @keep   nzl_u stock nz_ygap inflation ir rer
'wfsave(mode=update) data_for_proxysvar.xlsx @smpl 1985Q2 2017Q4  @keep Date  nzl_u stock nz_ygap inflation ir rer  policy_u
'wfsave(mode=update) data_for_proxysvar_bloom.xlsx @smpl 1985Q2 2017Q4  @keep  Date nzl_u stock nz_ygap inflation ir rer  bloomiv
'wfsave(mode=update, noid) ExtIV_bloom.xlsx @smpl 1985Q2 2017Q4  @keep  bloomiv

'wfsave(mode=update, noid) Narrative_IV_m.xlsx @smpl 1985Q2 2017Q4  @keep  policy_u


