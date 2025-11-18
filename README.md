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

The **Generalized Poisson Pseudo-Maximum Likelihood (GPPML)** estimation is implemented using a two-step procedure:

1.  **Diagnosis:** Run the standard PPML estimation (where $\lambda=1$) and use the resulting residuals and fitted values to estimate the optimal $\lambda$ parameter via **Iterated Generalized Method of Moments (GMM)** using `cvmrtest`.
2.  **Estimation:** Re-run the model using the `gppmlhdfe` command, inputting the estimated $\lambda$ value via the `lambda()` option to implement the GPPML weighting scheme.

### Implementation

The full GPPML procedure is executed as follows:

```stata
* Load example data
use gppmlhdfe_example.dta, clear

* Phase 1: PPML Estimation and Lambda Diagnosis ------------------------------

* Run standard PPML (Lambda = 1 implicitly). 
* 'd' saves the sum of FEs, and 'vce(cluster ...)' ensures clustered SEs.
ppmlhdfe trade BRDR CLNY CNTG DIST DIST_IN EU LANG RTA WTO, absorb(exp#year imp#year) d vce(cluster pair_id)

* Estimate Lambda using Iterated GMM (default) based on the PPML residuals.
cvmrtest, gmmtype(iterated) h0(1) lambda0(1)

* Store the estimated Lambda value, e(lambda_ppml), for use in the next step.
local lambda_ppml = e(lambda_ppml)

* Phase 2: GPPML Estimation --------------------------------------------------

* Run the GPPML estimator using the estimated Lambda.
gppmlhdfe trade BRDR CLNY CNTG DIST DIST_IN EU LANG RTA WTO, lambda(`lambda_ppml') absorb(exp#year imp#year) d vce(cluster pair_id)

