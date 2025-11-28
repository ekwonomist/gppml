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
{p2col :{cmd:cvmrtest} {hline 2}} Test of Constant Variance-Mean Ratio {p_end}
{p2col :{cmd:gppmlhdfe} {hline 2}} Generalized Poisson pseudo-likelihood regression with multiple levels of fixed effects{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:Syntax}


{p 8 15 2} {cmd:cvmrtest}
[{it:cvmrtest_options}] {p_end}

{p 8 15 2} {cmd:gppmlhdfe}
{depvar} [{indepvars}]
{ifin} {it:{weight}} {cmd:,} {opth lambda(#)} [{help ppmlhdfe##options:ppmlhdfe_options}] {p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:cvmrtest} is a post-estimation command designed to be run after {cmd:ppmlhdfe}. It estimates the optimal value of λ using an Iterated Generalized Method of Moments (iGMM) procedure. The estimated value is stored in the return list as {cmd:e(lambda)}, which can then be used with the {cmd:gppmlhdfe} command for the final estimation. λ is a variance parameter in the conditional variance function, such that Var(Y|x) = h*μ^(λ), where μ is the conditional mean of the dependent variable E(Y|x).

{pstd}
{cmd:gppmlhdfe} implements the {bf:Generalized Poisson Pseudo-Maximum Likelihood (GPPML)} estimator, which extends the standard Poisson pseudo-maximum likelihood (PPML) model to better handle overdispersion or underdispersion in the data. When {&lambda;} is set to 1, {cmd:gppmlhdfe} is equivalent to {cmd:ppmlhdfe}.

{marker cvmrtest}{...}
{title:cvmrtest Options}

{pstd}
{cmd:cvmrtest} is a post-estimation command that estimates λ using GMM.

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:GMM Estimation}
{synopt :{opt gmmtype(string)}}GMM estimation type: {cmd:onestep}, {cmd:twostep}, or {cmd:iterated} ({bf:default}).{p_end}
{synopt :{opt h0(real)}}Initial value for the $h$ parameter (default {bf:1}).{p_end}
{synopt :{opt lambda0(real)}}Initial value for the λ parameter (default {bf:1}).{p_end}
{synopt :{opt vce(string)}}VCE for GMM (default {cmd:robust}).{p_end}
{synopt :{opt igmmiterate(#)}}Max iterations for iterated GMM (default {bf:1000}).{p_end}
{synopt :{opt igmmeps(#)}}Convergence tolerance for the coefficient vector (default {bf:1e-6}).{p_end}
{synopt :{opt igmmweps(#)}}Convergence tolerance for the weighting matrix (default {bf:1e-6}).{p_end}
{synoptline}
{p2colreset}{...}


{marker options}{...}
{title:Options for gppmlhdfe}

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:GPPML Specific}
{synopt :{opth lambda(#)}}Sets the variance exponent λ in the GPPML weighting scheme,  This is the only option new to {cmd:gppmlhdfe} compared to {cmd:ppmlhdfe}.{p_end}

{syntab:Inherited Options}
{pstd}{bf:All other options} are identical to the {cmd:ppmlhdfe} command. See {browse "http://scorreia.com/research/ppmlhdfe.pdf":Correia, Guimarães, Zylkin (2019)} for details. These additional options include:
{p_end}
{synopt :{opth a:bsorb(ppmlhdfe##absvar:absvars)}}Categorical variables to be absorbed (fixed effects).{p_end}
{synopt :{opt vce}{cmd:(}{help ppmlhdfe##opt_vce:vcetype}{cmd:)}}Variance estimation (e.g., {cmd:robust}, {cmd:cluster}).{p_end}
{synopt :{opth exp:osure(varname)}}or {opth off:set(varname)} to include a variable with a coefficient constrained to 1.{p_end}
{synopt : {opth d(newvar)}}Save sum of fixed effects.{p_end}
{synopt :{opth sep:aration(string)}}Algorithm used to drop separated observations.{p_end}
{synopt :{opth tol:erance(#)}}IRLS convergence criterion.{p_end}
{synoptline}
{p2colreset}{...}



{marker citation}{...}
{title:Citation}

{pstd}
Sergio Correia, Paulo Guimarães, Thomas Zylkin: "ppmlhdfe: Fast Poisson Estimation with High-Dimensional Fixed Effects", 2019; {browse "http://arxiv.org/abs/1903.01690":arXiv:1903.01690}.

{pstd}
Kwon, Ohyun, Jangsu Yoon, & Yoto V. Yotov. 2025. "A Generalized Poisson-Pseudo Maximum Likelihood Estimator." {it:Journal of Business & Economic Statistics}, 1-14. https://doi.org/10.1080/07350015.2025.2544190.

{marker examples}{...}
{title:Examples}

{pstd}
The Generalized Poisson Pseudo-Maximum Likelihood (GPPML) procedure involves a two-step process: first, a diagnostic step using {cmd:cvmrtest} to estimate the optimal λ, followed by the final GPPML estimation.
{p_end}

{p 4 4 2}{cmd:* Phase 1: PPML Estimation and Lambda Diagnosis}{p_end}
{pstd}
First, run a standard PPML regression (λ=1 implicitly). Then, use {cmd:cvmrtest} to estimate the optimal λ using Iterated GMM based on the residuals.
{p_end}
{hline}
{phang2}{cmd:. use "https://raw.githubusercontent.com/ekwonomist/gppml/main/example/gppmlhdfe_example.dta", clear}{p_end}
{phang2}{cmd:. ppmlhdfe trade BRDR CLNY CNTG DIST DIST_IN EU LANG RTA WTO, absorb(exp#year imp#year) d vce(cluster pair_id)}{p_end}
{phang2}{cmd:. cvmrtest}{p_end}
{phang2}{cmd:. local lambda = e(lambda)}{p_end}
{hline}

{p 4 4 2}{cmd:* Phase 2: GPPML Estimation}{p_end}
{pstd}
Finally, run the GPPML estimator using the estimated λ.
{p_end}
{hline}
{phang2}{cmd:. gppmlhdfe trade BRDR CLNY CNTG DIST DIST_IN EU LANG RTA WTO, lambda(`lambda') absorb(exp#year imp#year) d vce(cluster pair_id)}{p_end}
{hline}



{marker contact}{...}
{title:Authors}

{pstd}Ohyun Kwon{break}
Drexel University{break}
Email: {browse "mailto:theekwonomist@gmail.com":theekwonomist@gmail.com}
{p_end}

{pstd}Jangsu Yoon{break}
University of Kentucky{break}
Email: {browse "mailto:jangsu.yoon@uky.edu":jangsu.yoon@uky.edu}
{p_end}

{pstd}Yoto V. Yotov{break}
Drexel University, ifo Institute, CESifo{break}
Email: {browse "mailto:yotov@drexel.edu":yotov@drexel.edu.}
{p_end}


{pstd}
The original {cmd:ppmlhdfe} package was developed by Sergio Correia, Paulo Guimarães, and Thomas Zylkin.
{p_end}
