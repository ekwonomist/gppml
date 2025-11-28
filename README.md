# 📦 `gppmlhdfe`: Generalized Poisson Pseudo-Maximum Likelihood with HDFE

This package implements the **Generalized Poisson Pseudo-Maximum Likelihood (GPPML)** estimator, extending the standard PPML regression with High-Dimensional Fixed Effects (HDFE) developed in the original `ppmlhdfe` project.

The package is designed to address potential (under)overdispersion by incorporating a $\lambda$ (Lambda) parameter into the estimation, following the methodology proposed by [Kwon, Yoon, and Yotov (2025)](https://www.tandfonline.com/doi/full/10.1080/07350015.2025.2544190?casa_token=B7Mmc3sogvwAAAAA%3Aok0ZuOu8Ty4I7PJakqMGK_NJAX9x1TY8UwM2M851KZe5NUX_8u_w0nYa57TMAhaknkN8EIHjyyG8NA). This two-step process allows for an empirically informed adjustment to the PPML estimator's weighting scheme.

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
| **Output** | Stores the estimated lambda value in the scalar `e(lambda)`. |
| Option | Description |
| `gmmtype(string)` | Specifies the GMM estimation method. Options are `onestep`, `twostep`, or `iterated` (default). |
| `h0(real)` | Sets the initial value for the parameter `h` in the GMM estimation. Default is `1`. |
| `lambda0(real)` | Sets the initial value for the parameter `lambda` in the GMM estimation. Default is `1`. |
| `vce(string)` | Specifies the type of standard error. Default is `robust`. See `help gmm` for more options. |
| `igmmiterate(#)` | Sets the maximum number of iterations for the iterated GMM estimator. Default is `1000`. |
| `igmmeps(#)` | Specifies the convergence tolerance for the coefficient vector in iterated GMM. Default is `1e-6`. |
| `igmmweps(#)` | Specifies the convergence tolerance for the weighting matrix in iterated GMM. Default is `1e-6`. |

---

### 2. `gppmlhdfe` (The Generalized PPML Estimator)

The core estimation command, which performs PPML regression with HDFE, utilizing the fast algorithms from `reghdfe`.

| Feature | Description |
| :--- | :--- |
| **Methodology** | Implementation of Poisson Pseudo-Maximum Likelihood (PPML) using **Iteratively Reweighted Least Squares (IRLS)**. |
| **Fixed Effects** | Handles multi-way High-Dimensional Fixed Effects (HDFE) using the `Absorb()` option. |
| **Separation** | Robust to statistical separation (zero-sum traps) using techniques like **FE**, **Simplex**, and **ReLU**. |
| **GPPML Extension**| Accepts a **`lambda(real)`** option, which generalizes the standard PPML estimation. The default value is $\lambda=1$. |
| **Dependencies** | Requires `ftools` (min. v2.45.0) and `reghdfe` (min. v6.0.2). |

---
## 🚀 Two-Step GPPML Estimation

The **Generalized Poisson Pseudo-Maximum Likelihood (GPPML)** estimation is implemented using a two-step procedure:

1.  **Diagnosis:** Run the standard PPML estimation (where $\lambda=1$) and use the resulting residuals and fitted values to estimate the optimal $\lambda$ parameter via **Iterated Generalized Method of Moments (GMM)** using `cvmrtest`.
    > **Interpretation:** If the null hypothesis $H_0: \lambda = 1$ cannot be rejected, standard PPML is efficient. If $H_0$ is rejected and the estimated $\lambda$ deviates significantly from 1, there is an efficiency gain from using GPPML. However, both PPML and GPPML remain econometrically consistent.

2.  **Estimation:** Re-run the model using the `gppmlhdfe` command, inputting the estimated $\lambda$ value via the `lambda()` option to implement the GPPML weighting scheme.

### 📥 Installation

```stata
* Install ftools
cap ado uninstall ftools
net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")

* Install reghdfe
cap ado uninstall reghdfe
net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/")

* Install ppmlhdfe
cap ado uninstall ppmlhdfe
net install ppmlhdfe, from("https://raw.githubusercontent.com/sergiocorreia/ppmlhdfe/master/src/")

* Create compiled files
ftools, compile
reghdfe, compile

* Install gppmlhdfe
cap ado uninstall gppmlhdfe
net install gppmlhdfe, from("https://raw.githubusercontent.com/ekwonomist/gppml/main/gppml/")
```


### ▶️ Implementation

The full GPPML procedure is executed as follows:

```stata
* Load example data
use "https://raw.githubusercontent.com/ekwonomist/gppml/main/example/gppmlhdfe_example.dta", clear

* Phase 1: PPML Estimation and Lambda Diagnosis ------------------------------

* Run standard PPML (Lambda = 1 implicitly). 
* 'd' saves the sum of FEs, and 'vce(cluster ...)' ensures clustered SEs.
ppmlhdfe trade BRDR CLNY CNTG DIST DIST_IN EU LANG RTA WTO, absorb(exp#year imp#year) d vce(cluster pair_id)

* Estimate Lambda using Iterated GMM (default) based on the PPML residuals.
cvmrtest, gmmtype(iterated) h0(1) lambda0(1)

* Store the estimated Lambda value, e(lambda), for use in the next step.
local lambda = e(lambda)

* Phase 2: GPPML Estimation --------------------------------------------------

* Run the GPPML estimator using the estimated Lambda.
gppmlhdfe trade BRDR CLNY CNTG DIST DIST_IN EU LANG RTA WTO, lambda(`lambda') absorb(exp#year imp#year) d vce(cluster pair_id)
```

## 📢 Recent updates

- **Version 0.1.1 (November 25, 2025):** Initial release.

## 📚 Citation

#### As text

- Kwon, Ohyun, Jangsu Yoon, and Yoto V. Yotov. 2025. “A Generalized Poisson-Pseudo Maximum Likelihood Estimator.” *Journal of Business & Economic Statistics* 0 (ja): 1–27. https://doi.org/10.1080/07350015.2025.2544190.

#### As BibTex

```bibtex
@article{kwon2025GeneralizedPoissonPseudo,
  title = {A Generalized Poisson-Pseudo Maximum Likelihood Estimator},
  author = {Kwon, Ohyun and Yoon, Jangsu and Yotov, Yoto V.},
  year = 2025,
  journal = {Journal of Business \& Economic Statistics},
  volume = {0},
  number = {ja},
  pages = {1--27},
  publisher = {ASA Website},
  issn = {0735-0015},
  doi = {10.1080/07350015.2025.2544190}
}
```
