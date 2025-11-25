use gppmlhdfe_example.dta, clear
ppmlhdfe trade BRDR CLNY CNTG DIST DIST_IN EU LANG RTA WTO, absorb(exp#year imp#year) d vce(cluster pair_id)
cvmrtest, gmmtype(iterated) h0(1) lambda0(1)
local lambda_ppml = e(lambda_ppml)
gppmlhdfe trade BRDR CLNY CNTG DIST DIST_IN EU LANG RTA WTO, lambda(`lambda_ppml') absorb(exp#year imp#year) d vce(cluster pair_id)

