program define cvmrtest, eclass
    version 13.0
    syntax [, GMMType(string) H0(real 1) LAMbda0(real 1) VCE(string) ///
              IGMMITERATE(integer 1000) IGMMeps(real 1e-6) IGMMweps(real 1e-6)]

    // Validate gmmtype option
    local gmmopt "igmm" // Default to iterated GMM
    if `"`gmmtype'"' != "" {
        if `"`gmmtype'"' == "onestep" {
            local gmmopt "onestep"
        }
        else if `"`gmmtype'"' == "twostep" {
            local gmmopt "twostep"
        }
        else if `"`gmmtype'"' == "iterated" {
            local gmmopt "igmm"
        }
        else {
            di as err "gmmtype() must be onestep, twostep, or iterated"
            exit 198
        }
    }

    // Set default VCE
    if `"`vce'"' == "" {
        local vce "robust"
    }
    
    // Collect IGMM options if gmmtype is iterated
    local igmmopts ""
    if "`gmmopt'" == "igmm" {
        local igmmopts "igmmiterate(`igmmiterate') igmmeps(`igmmeps') igmmweps(`igmmweps')"
    }

    // Predict fitted values from last estimation
    tempvar yhat_ppml resid2 xbhat
    qui predict `yhat_ppml'

    // Remove _cons from independent variables
    local indepvars_no_cons: di subinword("`e(indepvars)'", "_cons", "", 1)

    // Squared residuals
    qui gen `resid2' = (`e(depvar)' - `yhat_ppml')^2

    // Log of fitted values, with lower bound
    qui gen `xbhat' = log(`yhat_ppml')
    qui replace `xbhat' = log(1e-6) if `xbhat' < log(1e-6) & `xbhat' < .

    // GMM estimation
    gmm ( `resid2' - {h} * exp({lambda} * `xbhat') ), ///
        `gmmopt' ///
        `igmmopts' ///
        derivative(/h = -1 * exp({lambda} * `xbhat')) ///
        derivative(/lambda = -1 * {h} * `xbhat' * exp({lambda} * `xbhat')) ///
        instruments("`indepvars_no_cons'") ///
        winitial(identity) ///
        vce(`vce') /// 
        from(h `h0' lambda `lambda0') 

    // Store lambda estimate
    matrix lambdaiGMMeb0 = e(b)
    local lambda = lambdaiGMMeb0[1,2]

    // Return lambda as a scalar
    ereturn scalar lambda = `lambda'
end


