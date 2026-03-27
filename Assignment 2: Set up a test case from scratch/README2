# Assignment 2: Axisymmetric Turbulent Jet Simulation with SU2

**Solver:** INC_RANS &nbsp;|&nbsp; **Version:** SU2_CFD 8.4.0 "Harrier" &nbsp;|&nbsp; **Author:** Kareem A. Eldesouki

---

## Abstract

This report presents a steady-state, axisymmetric RANS simulation of a turbulent water jet at **Re = 2000** using the SU2 incompressible solver. The SST turbulence model is validated against Particle Image Velocimetry (PIV) data from Fukushima et al. Key results include correct identification of a potential core length of ~6D, far-field self-similarity confirmed for $x/D \geq 90$, and a quantitative assessment of how the ambient co-flow shifts the jet decay characteristics relative to the zero-co-flow experiment.

<img width="2106" height="1114" alt="Axial velocity contour overview" src="https://github.com/user-attachments/assets/f70b9a4c-38b5-4c91-a8fa-d82e93878a56" />

*Figure 1 — Axial velocity contour of the simulated turbulent jet.*

---

## 1. Introduction

The axisymmetric turbulent jet is a canonical benchmark for free shear flows, offering a rigorous test of mesh resolution, turbulence model accuracy, and boundary condition sensitivity. The flow physics are governed by the interaction between a high-momentum core and the surrounding fluid across a developing shear layer, where both large-scale eddies and fine-scale turbulence drive momentum transfer outward from the jet axis.

At **Re = 2000**, the flow sits in a transitional turbulence regime, making it a sensitive test case for RANS closures. The goal of this study is to reproduce the experimental self-similar velocity profiles reported by Fukushima et al. and to assess the influence of a 1 m/s ambient co-flow on jet decay.

---

## 2. Problem Setup

### 2.1 Geometry and Domain

A **2D axisymmetric configuration** was adopted in place of a full 3D pipe, substantially reducing computational cost while preserving the rotational symmetry of the flow. The mesh was generated in **Gmsh** using structured quadrilateral elements.

The domain was dimensioned relative to the nozzle diameter ($D = 1\ \text{mm}$) to allow full natural jet development and prevent boundary-induced backflow:

| Direction  | Final Extent | Rationale                                                 |
|------------|--------------|-----------------------------------------------------------|
| Downstream | 1100D        | Captures full velocity decay to ambient level             |
| Radial     | 200D         | Prevents pressure confinement; allows lateral dissipation |
| Upstream   | 10D          | Buffers inlet against entrainment-driven suction          |

> **Domain sizing study:** An initial downstream extent of 400D produced oscillating, non-converging residuals. Extending the domain to 1100D downstream and doubling the radial extent to 200D resolved this instability by allowing adverse pressure gradients near the outlet to fully dissipate. See Section 2.2 for convergence history from this study.

### 2.2 Mesh Generation and Refinement

The domain was partitioned into **three structured regions** to concentrate resolution near the nozzle exit and jet shear layer while coarsening toward the far field. All regions were meshed with quadrilateral elements.

<img width="363" height="547" alt="Domain partition schematic" src="https://github.com/user-attachments/assets/386e0606-e092-4ad5-b1f8-bf1421790490" />

*Figure 2 — Three-region domain partition used for structured quad generation in Gmsh.*

<img width="602" alt="Mesh refinement near nozzle" src="https://github.com/user-attachments/assets/aca321ab-4f8d-4afb-8aa6-151985cddbe5" />

*Figure 3 — Mesh refinement detail near the nozzle exit and jet shear layer.*

<img width="1002" height="209" alt="Full mesh overview" src="https://github.com/user-attachments/assets/7f28ce84-f6d4-4f54-80d4-a798eb2ee7e6" />

*Figure 4 — Full structured mesh overview showing the three-region layout.*

The convergence history below is from the domain sizing study. The bounded oscillations in the short-domain (400D) case directly motivated the final domain dimensions.

<img width="1102" height="469" alt="Convergence history — domain sizing study" src="https://github.com/user-attachments/assets/ac5dc407-d9d9-4729-8a1a-7ed741cac1a4" />

*Figure 5 — Convergence history for the domain sizing study. Bounded oscillations in the 400D case were eliminated by extending the downstream domain to 1100D and doubling the radial extent.*

---

## 3. Numerical Configuration

### 3.1 Fluid Properties

Water was used as the working fluid to match the conditions of the Fukushima et al. experiment. The inlet velocity was set to 2.0 m/s to achieve the target Reynolds number, while the ambient co-flow was set to 1.0 m/s.

| Parameter                   | Value             |
|-----------------------------|-------------------|
| Density ($\rho$)            | 998.2 kg/m³       |
| Dynamic viscosity ($\mu$)   | 1.002 × 10⁻³ Pa·s |
| Jet inlet velocity ($U_0$)  | 2.0 m/s           |
| Ambient co-flow ($U_a$)     | 1.0 m/s           |
| Reynolds number             | 2000              |

### 3.2 Turbulence Model

The **Menter Shear Stress Transport (SST)** model was selected over Spalart–Allmaras (SA). SST's blending between the $k$–$\omega$ formulation near walls and $k$–$\varepsilon$ in the free stream makes it better suited to the strong shear gradient at the jet–ambient interface than a one-equation model. Since the primary interest is in steady-state mean-flow quantities, RANS is appropriate and computationally tractable.

### 3.3 Numerical Schemes

| Setting               | Choice                          | Rationale                                                   |
|-----------------------|---------------------------------|-------------------------------------------------------------|
| Convective scheme     | FDS                             | Greater stability than ROE at low Mach, incompressible flow |
| Linear solver         | FGMRES                          | Handles the stiff SST-coupled system effectively            |
| Reconstruction        | MUSCL + Venkatakrishnan limiter | Second-order accuracy with suppressed spurious oscillations |
| Gradient computation  | Green–Gauss                     | Well-suited to structured quad meshes                       |
| Convergence field     | RMS pressure residual           | Most sensitive indicator for this incompressible case       |
| Convergence criterion | $10^{-7}$                       | Strict criterion to ensure a true steady state              |

### 3.4 Full Solver Configuration

```ini
% --- SOLVER SETTINGS ---
SOLVER= INC_RANS
KIND_TURB_MODEL= SST
AXISYMMETRIC= YES
REF_DIMENSIONALIZATION= DIMENSIONAL

% --- FLUID PROPERTIES & INITIALIZATION ---
INC_DENSITY_INIT= 998.2
INC_VELOCITY_INIT= (1.0, 0.0, 0.0)   % Ambient co-flow; used as SU2 internal reference
MU_CONSTANT= 1.002E-3

% --- NUMERICS ---
CFL_NUMBER= 1.0
LINEAR_SOLVER= FGMRES
CONV_NUM_METHOD_FLOW= FDS
MUSCL_FLOW= YES
SLOPE_LIMITER_FLOW= VENKATAKRISHNAN
TIME_DOMAIN= NO
CONV_FIELD= RMS_PRESSURE
CONV_RESIDUAL_MINVAL= -9
```

> **SU2 reference velocity note:** `INC_VELOCITY_INIT` is set to the ambient co-flow velocity (1.0 m/s), not the jet inlet velocity. SU2 uses this initialization value as its internal reference quantity, which must be accounted for when interpreting non-dimensional outputs in co-flow configurations.

### 3.5 Boundary Conditions

```ini
% Nozzle wall — no-slip, isothermal
MARKER_ISOTHERMAL= ( wall, 288.0 )

% Jet axis — symmetry
MARKER_SYM= ( symmetric )

% Internal interface between mesh regions
MARKER_INTERNAL= ( internal )

% Jet inlet — prescribed velocity
INC_INLET_TYPE= VELOCITY_INLET
MARKER_INLET= ( inlet, 288.0, 2.0, 1.0, 0.0, 0.0 )

% Far-field and outlet — zero gauge pressure
INC_OUTLET_TYPE= PRESSURE_OUTLET
MARKER_OUTLET= ( outlet, 0.0 )

MARKER_MONITORING= ( wall )
```

| Boundary    | Type                    | Value                       |
|-------------|-------------------------|-----------------------------|
| Jet inlet   | Velocity inlet          | $U = 2.0$ m/s, $T = 288$ K |
| Nozzle wall | No-slip isothermal wall | $T = 288$ K                 |
| Axis        | Symmetry                | —                           |
| Outlet      | Pressure outlet         | $p_\text{gauge} = 0$ Pa     |

---

## 4. Convergence

A constant **CFL = 1.0** was used throughout. An adaptive strategy was tested across CFL values of 0.1, 1, 2, and 10, but all cases produced equivalent convergence rates and wall-clock runtimes. The final simulation converged smoothly to a residual of $\mathbf{10^{-7}}$ in RMS pressure with no oscillations.

<img width="1291" height="990" alt="Convergence history — final simulation" src="https://github.com/user-attachments/assets/85532467-b9cd-46d4-8f16-465b0e2097e7" />

*Figure 6 — Convergence history for the final simulation (1100D domain). Smooth monotonic decay to the $10^{-7}$ criterion.*

---

## 5. Results and Validation

### 5.1 Axial Velocity Decay and Potential Core

The simulation reproduces both characteristic regions of the turbulent jet:

**Potential core** — The centerline velocity remains at ≥ 90% of the inlet value ($U_0 = 2.0$ m/s) up to $x/D \approx 6$, consistent with experimental expectations for this nozzle geometry and Reynolds number.

<img width="1629" height="881" alt="Centerline velocity decay profile" src="https://github.com/user-attachments/assets/1ff74b54-ea78-4f27-82c0-3a18a5f3b2af" />

*Figure 7 — Centerline velocity decay. The potential core (≥ 90% of peak) extends to approximately 6D before the onset of turbulent mixing.*

**Far-field decay** — Beyond the potential core, the centerline velocity decays monotonically and fully merges with the 1.0 m/s ambient co-flow by $x/D \approx 60$. In the non-dimensional velocity space used throughout (normalized by $U_0 = 2.0$ m/s), the ambient co-flow corresponds to a value of 0.5.

<img width="2152" height="1136" alt="Full-domain axial velocity contour" src="https://github.com/user-attachments/assets/a5e30409-24dd-4b34-a8a4-02e193697941" />

*Figure 8 — Full-domain axial velocity contour. The jet fully merges with the ambient co-flow by $x/D \approx 60$.*

### 5.2 Self-Similarity Analysis and Co-flow Effect

Far-field jet behavior was assessed using the **velocity excess ratio**:

$$\frac{U - U_a}{U_c - U_a}$$

where $U$ is the local axial velocity, $U_a = 1.0$ m/s is the ambient co-flow, and $U_c$ is the local centerline velocity. A linear trend in the inverse centerline excess confirms self-preserving decay, with $R^2 \approx 0.99$.

<img width="1842" height="1165" alt="Inverse centerline decay — self-similarity fit" src="https://github.com/user-attachments/assets/9754ee57-f839-4817-9b80-e47c8a8dcc44" />

*Figure 9 — Inverse centerline velocity excess vs. axial distance. The linear fit ($R^2 \approx 0.99$) confirms mathematically self-similar decay in the far field.*

**Comparison with Fukushima et al.:** The reference experiment used a zero co-flow condition ($U_a = 0$). The present co-flow of 1.0 m/s substantially reduces the shear gradient at the jet boundary, suppressing lateral spreading and significantly altering the decay parameters:

| Parameter              | Fukushima et al. ($U_a = 0$) | Present ($U_a = 1.0$ m/s) |
|------------------------|------------------------------|---------------------------|
| Decay constant $B$     | ~6 (typical range)           | ~113                      |
| Virtual origin $x_0/D$ | near 0                       | ~−173                     |

The large shift in both $B$ and $x_0$ is a direct physical consequence of the reduced shear driven by co-flow, not a numerical artifact.

### 5.3 Radial Profile Collapse

Fukushima et al. report that turbulent jets reach a **self-preserving state** for $30 \leq x/D \leq 130$. In this regime, radial velocity profiles normalized by the local centerline velocity $U_c$ should collapse onto a universal curve when plotted against the similarity variable:

$$\eta = \frac{r}{x - x_0}$$

where $r$ is the radial coordinate and $x_0$ is the virtual origin from the linear fit in Section 5.2.

<img width="2054" height="1202" alt="Normalized radial profile collapse" src="https://github.com/user-attachments/assets/141d7dc5-2e34-49f5-90f6-91a60258b9cb" />

*Figure 10 — Normalized radial velocity profiles at $x/D = 60,\ 90,\ 100,\ 130,$ and $160$. Strong collapse is observed for $x/D \geq 90$, confirming the self-preserving regime.*

The profiles at $x/D = 90, 100, 130,$ and $160$ show strong qualitative collapse, confirming that the solver captures the self-similar regime. The profile at $x/D = 60$, however, appears broader and flatter — indicating the **simulated jet spreads more slowly** than the physical experiment in the near field. Two contributing factors are identified:

1. **Co-flow suppression of near-field mixing:** The 1.0 m/s ambient velocity reduces the shear gradient at the jet boundary, delaying the onset of self-similarity relative to the zero-co-flow Fukushima experiment. This is the dominant contributing factor.

2. **Turbulence model and numerical scheme sensitivity:** At Re = 2000, early-stage shear layer mixing is sensitive to turbulence model constants and numerical diffusion. Higher-order turbulence variable reconstruction or a refined near-field mesh may advance the self-similarity onset.

---

## 6. Discussion and Recommendations

The simulation successfully captures the key physics of the axisymmetric turbulent jet: a well-defined potential core, monotonic centerline decay to the ambient, and confirmed far-field self-similarity. The discrepancy at $x/D = 60$ is physically explicable and does not undermine the validity of the far-field validation.

The following recommendations are made for future simulations of this class:

**Domain sizing** — A downstream extent of at least 1100D and radial extent of 200D are recommended. Insufficient domain size causes pressure reflections at the outlet that produce bounded residual oscillations and non-physical near-boundary flow.

**Upstream buffer** — A 10D upstream section is essential to accommodate the low-pressure region created by jet entrainment. Omitting this buffer consistently leads to inlet backflow and divergence.

**SU2 reference velocity** — `INC_VELOCITY_INIT` serves as SU2's internal reference quantity. In co-flow problems this must be set to the ambient velocity, and all non-dimensional post-processing must account for this choice explicitly.

**CFL selection** — CFL = 1.0 provides stable convergence for this mesh resolution. For more refined meshes, a modestly higher CFL may improve stability; adaptive ramping offered no benefit in the present case.

**Future improvements** — To better resolve near-field mixing and correct the delayed self-similarity at $x/D = 60$: (1) apply second-order reconstruction to the turbulence transport equations, (2) increase mesh resolution within the first 10D of the shear layer, and (3) perform a sensitivity study on SST model constants tuned for transitional co-flow jets at Re = 2000.

---

## References

- C. Fukushima et al., PIV measurements of a turbulent round jet — experimental dataset used for validation.
- Menter, F. R., "Two-Equation Eddy-Viscosity Turbulence Models for Engineering Applications," *AIAA Journal*, Vol. 32, No. 8, 1994.
- SU2 Development Team, *SU2 v8.4.0 "Harrier" Documentation*, [su2code.github.io](https://su2code.github.io).
