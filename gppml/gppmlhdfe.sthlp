{smcl}
{* *! version 0.1.1 25nov2025}{...}
{vieweralsosee "[R] poisson" "help poisson"}{...}
{vieweralsosee "reghdfe" "help reghdfe"}{...}
{vieweralsosee "ppmlhdfe" "help ppmlhdfe"}{...}
{viewerjumpto "Syntax" "gppmlhdfe##syntax"}{...}
{viewerjumpto "Description" "gppmlhdfe##description"}{...}
{viewerjumpto "Options" "gppmlhdfe##options"}{...}
{viewerjumpto "cvmrtest" "gppmlhdfe##cvmrtest"}{...}
{viewerjumpto "Examples" "gppmlhdfe##examples"}{...}
{viewerjumpto "Authors" "gppmlhdfe##authors"}{...}
{viewerjumpto "Citation" "gppmlhdfe##citation"}{...}
{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{cmd:cvmrtest} {hline 2}} Test of Constant Variance-Mean Ratio{p_end}
{p2col :{cmd:gppmlhdfe} {hline 2}} Generalized Poisson pseudo-likelihood regression with multiple levels of fixed effects{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}

{p 8 15 2} {cmd:gppmlhdfe}
{depvar} [{indepvars}]
{ifin} {it:{weight}} {cmd:,} {opth lambda(#)} [{help ppmlhdfe##options:ppmlhdfe_options}] {p_end}

{p 8 15 2} {cmd:cvmrtest}
[{it:cvmrtest_options}] {p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:gppmlhdfe} implements the {bf:Generalized Poisson Pseudo-Maximum Likelihood (GPPML)} estimator. It extends the standard PPML estimation with multi-way fixed effects (HDFE) by incorporating a $\lambda$ (Lambda) parameter to address issues of (under)overdispersion. The default $\lambda=1$ reverts the estimator to standard PPML.

{pstd}
The companion command, {cmd:cvmrtest}, is a post-estimation tool that estimates the optimal $\lambda$ parameter using an {bf:Iterated Generalized Method of Moments (GMM)} procedure. The estimated value is stored in {cmd:e(lambda)} for use in the {cmd:gppmlhdfe} command.

{marker options}{...}
{title:Options for gppmlhdfe}

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:GPPML Specific}
{synopt :{opth lambda(#)}}Sets the variance exponent $\lambda$ in the GPPML weighting scheme, $\text{Var}(Y|x) = \phi \mu^\lambda$. The default is {bf:1} (standard PPML). This is the only option new to {cmd:gppmlhdfe} compared to {cmd:ppmlhdfe}.{p_end}

{syntab:Inherited Options}
{pstd}{bf:All other options} are identical to the {cmd:ppmlhdfe} command. These include:
{p_end}
{synopt :{opth a:bsorb(ppmlhdfe##absvar:absvars)}}Categorical variables to be absorbed (fixed effects).{p_end}
{synopt :{opt vce}{cmd:(}{help ppmlhdfe##opt_vce:vcetype}{cmd:)}}Variance estimation (e.g., {cmd:robust}, {cmd:cluster}).{p_end}
{synopt :{opth exp:osure(varname)}}or {opth off:set(varname)} to include a variable with a coefficient constrained to 1.{p_end}
{synopt : {opth d(newvar)}}Save sum of fixed effects.{p_end}
{synopt :{opth sep:aration(string)}}Algorithm used to drop separated observations.{p_end}
{synopt :{opth tol:erance(#)}}IRLS convergence criterion.{p_end}
{synoptline}
{p2colreset}{...}

{marker cvmrtest}{...}
{title:cvmrtest Options}

{pstd}
{cmd:cvmrtest} is a post-estimation command that estimates $\lambda$ using GMM.

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:GMM Estimation}
{synopt :{opt gmmtype(string)}}GMM estimation type: {cmd:onestep}, {cmd:twostep}, or {cmd:iterated} ({bf:default}).{p_end}
{synopt :{opt h0(real)}}Initial value for the $h$ parameter (default {bf:1}).{p_end}
{synopt :{opt lambda0(real)}}Initial value for the $\lambda$ parameter (default {bf:1}).{p_end}
{synopt :{opt vce(string)}}VCE for GMM (default {cmd:robust}).{p_end}
{synopt :{opt igmmiterate(#)}}Max iterations for iterated GMM (default {bf:1000}).{p_end}
{synopt :{opt igmmeps(#)}}Convergence tolerance for the coefficient vector (default {bf:1e-6}).{p_end}
{synopt :{opt igmmweps(#)}}Convergence tolerance for the weighting matrix (default {bf:1e-6}).{p_end}
{synoptline}
{p2colreset}{...}

{marker examples}{...}
{title:Two-Step GPPML Implementation}

{pstd}The full GPPML procedure involves a diagnostic step with {cmd:cvmrtest} to estimate $\lambda$, followed by the final GPPML estimation.

{p 4 4 2}{cmd:* Phase 1: PPML Estimation and Lambda Diagnosis}
{stata "ppmlhdfe trade BRDR CLNY CNTG DIST DIST_IN EU LANG RTA WTO, absorb(exp#year imp#year) d vce(cluster pair_id)":. ppmlhdfe trade BRDR CLNY CNTG DIST DIST_IN EU LANG RTA WTO, absorb(exp#year imp#year) d vce(cluster pair_id)}
{pstd}Run standard PPML ($\lambda=1$).

{stata "cvmrtest, gmmtype(iterated) h0(1) lambda0(1)":. cvmrtest, gmmtype(iterated) h0(1) lambda0(1)}
{pstd}Estimate $\lambda$ using Iterated GMM.

{stata "local lambda = e(lambda)":. local lambda = e(lambda)}
{pstd}Store the estimated $\lambda$ value, {cmd:e(lambda)}.

{p 4 4 2}{cmd:* Phase 2: GPPML Estimation}
{stata "gppmlhdfe trade BRDR CLNY CNTG DIST DIST_IN EU LANG RTA WTO, lambda(`lambda') absorb(exp#year imp#year) d vce(cluster pair_id)":. gppmlhdfe trade BRDR CLNY CNTG DIST DIST_IN EU LANG RTA WTO, lambda(`lambda') absorb(exp#year imp#year) d vce(cluster pair_id)}
{pstd}Run the GPPML estimator using the estimated $\lambda$.

{marker authors}{...}
{title:Authors}

{pstd}The original {cmd:ppmlhdfe} package was developed by Sergio Correia, Paulo Guimarães, and Thomas Zylkin.{p_end}
{pstd}The {cmd:gppmlhdfe} extension is authored by:{p_end}

{p 8 16 2}Ohyun Kwon{p_end}
{p 8 16 2}Jangsu Yoon{p_end}
{p 8 16 2}Yoto V. Yotov{p_end}

{marker citation}{...}
{title:Citation}

{pstd}
{p 4 8 2}Kwon, Ohyun, Jangsu Yoon, and Yoto V. Yotov. 2025. “A Generalized Poisson-Pseudo Maximum Likelihood Estimator.” {it:Journal of Business & Economic Statistics} 0 (ja): 1–27. {browse "https://doi.org/10.1080/07350015.2025.2544190":https://doi.org/10.1080/07350015.2025.2544190}.{p_end}

{pstd}
For the base {cmd:ppmlhdfe} methodology:{p_end}
{p 4 8 2}Sergio Correia, Paulo Guimarães, Thomas Zylkin: "ppmlhdfe: Fast Poisson Estimation with High-Dimensional Fixed Effects", 2019; {browse "http://arxiv.org/abs/1903.01690":arXiv:1903.01690}.{p_end}