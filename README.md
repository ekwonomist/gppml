# `gppmlhdfe`: Generalized Poisson Pseudo-Maximum Likelihood with HDFE

This package implements the **Generalized Poisson Pseudo-Maximum Likelihood (GPPML)** estimator, extending the standard PPML regression with High-Dimensional Fixed Effects (HDFE) developed in the original `ppmlhdfe` project.

The package is designed to address potential misspecification or overdispersion by incorporating a $\lambda$ (Lambda) parameter into the estimation, following the methodology proposed by Kwon, Yoon, and Yotov (2025). This two-step process allows for an empirically informed adjustment to the PPML estimator's weighting scheme.

---

## 🛠️ Components

The package consists of two primary Stata commands: `cvmrtest` (the diagnostic tool) and `gppmlhdfe` (the estimator).

### 1. `cvmrtest` (The Lambda Diagnostic and Estimation)

A post-estimation command used to estimate the optimal $\lambda$ parameter necessary for the GPPML model.

| Feature | Description |
| :--- | :--- |
| **Purpose** | Estimates the parameter $\lambda_{\text{ppml}}$ using the **Generalized Method of Moments (GMM)**. |
| **Moment Condition** | The GMM is based on the moment condition: $\text{E}[\text{resid}^2 - h \cdot \exp(\lambda \cdot \ln(\mu))] = 0$, where $\text{resid}^2$ is the squared residual and $\mu$ is the fitted value. |
| **GMM Types** | Supports `onestep`, `twostep`, or `iterated` GMM estimation. |
| **Output** | Stores the estimated lambda value in the scalar `e(lambda_ppml)`. |

---

### 2. `gppmlhdfe` (The Generalized PPML Estimator)

The core estimation command, which performs PPML regression with HDFE, utilizing the fast algorithms from `reghdfe`.

| Feature | Description |
| :--- | :--- |
| **Methodology** | Implementation of Poisson Pseudo-Maximum Likelihood (PPML) using **Iteratively Reweighted Least Squares (IRLS)**. |
| **Fixed Effects** | Handles multi-way High-Dimensional Fixed Effects (HDFE) using the `Absorb()` option. |
| **Separation** | Robust to statistical separation (zero-sum traps) using techniques like **FE**, **Simplex**, and **ReLU**. |
| **GPPML Extension**| Accepts a **`LAMbda(real)`** option, which generalizes the standard PPML estimation. The default value is $\lambda=1$. |
| **Dependencies** | Requires `ftools` (min. v2.45.0) and `reghdfe` (min. v6.0.2). |

---

## 🚀 Two-Step GPPML Estimation

The recommended approach involves two steps: first, run the standard PPML and use `cvmrtest` to estimate $\lambda$; second, re-run the regression using the estimated $\lambda$ in `gppmlhdfe`'s `lambda()` option.

### Step 1: Run Standard PPML and Estimate $\lambda$

```stata
* Load example data
use gppmlhdfe_example.dta, clear

* Step 1: Run standard PPML (Lambda = 1 implicitly) and estimate Lambda.
* The 'd' option saves the sum of FEs, and 'vce(cluster ...)' ensures clustered SEs.
ppmlhdfe trade BRDR CLNY CNTG DIST DIST_IN EU LANG RTA WTO, absorb(exp#year imp#year) d vce(cluster pair_id)

* Estimate Lambda using Iterated GMM (default) based on the PPML residuals.
cvmrtest, gmmtype(iterated) h0(1) lambda0(1)

* Store the estimated Lambda value, e(lambda_ppml).
local lambda_ppml = e(lambda_ppml)

* Step 2: Run the GPPML estimator using the estimated Lambda.
gppmlhdfe trade BRDR CLNY CNTG DIST DIST_IN EU LANG RTA WTO, lambda(`lambda_ppml') absorb(exp#year imp#year) d vce(cluster pair_id)

