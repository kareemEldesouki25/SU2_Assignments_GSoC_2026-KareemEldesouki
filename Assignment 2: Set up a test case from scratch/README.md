
# Assignment 2: Axisymmetric Turbulent Jet Simulation with SU2

**Solver:** INC_RANS  
**Version:** SU2_CFD 8.4.0 "Harrier"  
**Author:** Kareem A. Eldesouki  

---

## At a Glance

This report presents a steady-state, axisymmetric RANS simulation of a turbulent water jet at **Re = 2000** using the SU2 incompressible solver. The SST turbulence model is validated against Particle Image Velocimetry (PIV) data from Fukushima et al. Key results include correct identification of a potential core length of ~6D, far-field self-similarity confirmed for $x/D \geq 90$, and a quantitative assessment of how the ambient co-flow shifts the jet decay characteristics relative to the zero-co-flow experiment.

<img width="2106" height="1114" alt="Axial velocity contour overview" src="https://github.com/user-attachments/assets/f70b9a4c-38b5-4c91-a8fa-d82e93878a56" />

*Figure 1 — Axial velocity contour of the simulated turbulent jet.*

---

## 1.Motivation for Setup

The axisymmetric turbulent jet is a foundational CFD benchmark. It provides a rigorous test for mesh resolution, turbulence model accuracy, and the influence of boundary conditions in free shear layers. 
The physics involves the interaction between a high-momentum core and the stagnant surrounding fluid. This interaction occurs across a shear layer where large-scale eddies and small-scale turbulence facilitate momentum transfer.

At **Re = 2000**, the flow sits in a transitional turbulence regime, making it a sensitive test case for RANS closures. The goal of this study is to reproduce the experimental self-similar velocity profiles reported by **Fukushima et al.** 

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

> **Domain sizing study:** An initial downstream extent of 400D produced oscillating, non-converging residuals . Extending the domain to 1100D downstream and doubling the radial extent to 200D resolved this instability by allowing adverse pressure gradients near the outlet to fully dissipate. See Section 2.2 for convergence history from this study.

### 2.2 Mesh Generation and Refinement

The domain was partitioned into **three structured regions** to concentrate resolution near the nozzle exit and jet shear layer while coarsening toward the far field. All regions were meshed with quadrilateral elements.

<img width="363" height="547" alt="Domain partition schematic" src="https://github.com/user-attachments/assets/386e0606-e092-4ad5-b1f8-bf1421790490" />

*Figure 2 — Three-region domain partition used for structured quad generation in Gmsh.*

<img width="602" alt="Mesh refinement near nozzle" src="https://github.com/user-attachments/assets/aca321ab-4f8d-4afb-8aa6-151985cddbe5" />

*Figure 3 — Mesh refinement detail near the nozzle exit and jet shear layer.*

<img width="1002" height="209" alt="Full mesh overview" src="https://github.com/user-attachments/assets/7f28ce84-f6d4-4f54-80d4-a798eb2ee7e6" />

*Figure 4 — Full structured mesh overview showing the three-region layout.*

The convergence history below is from the domain sizing study. The bounded oscillations in the short-domain **(400D)** case directly motivated the final domain dimensions.

<img width="1773" height="1144" alt="570332009-85532467-b9cd-46d4-8f16-465b0e2097e7" src="https://github.com/user-attachments/assets/f7ee8fe8-b226-4e32-9cd5-046a822f61b9" />

*Figure 5 — Convergence history for the initial domain sizing of the 400D case. We can see a slight oscillation in residuals, and could not exceed a 1e-8 residual no matter how many iterations we increase.*

<img width="1773" height="1144" alt="image" src="https://github.com/user-attachments/assets/5bb31971-7cab-4b41-a926-3ac9f0e65e9f" />

*Figure 5 — Smooth convergence after mesh refinement and extending the domain to 1100D x 200D, reaching 1e-10*

---

## 3. Numerical Configuration

### 3.1 Fluid Properties

Water was used as the working fluid to match the conditions of the **Fukushima et al.** experiment. The inlet velocity was set to 2.0 m/s to achieve the target Reynolds number, while the ambient co-flow was initialised with 1.0 m/s.

| Parameter                   | Value             |
|-----------------------------|-------------------|
| Density ($\rho$)            | 998.2 kg/m³       |
| Dynamic viscosity ($\mu$)   | 1.002 × 10⁻³ Pa·s |
| Jet inlet velocity ($U_0$)  | 2.0 m/s           |
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

A constant **CFL = 1.0** was used throughout. An adaptive strategy was tested across CFL values of 0.1, 1, 10, and 100,and higher values speeds up the simulation with mesh refinemnt. The final simulation converged smoothly to a residual of $\mathbf{10^{-7}}$ in RMS pressure with no oscillations.

<img width="1773" height="1144" alt="image" src="https://github.com/user-attachments/assets/5bb31971-7cab-4b41-a926-3ac9f0e65e9f" />

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

## 6. Lessons Learned

* **SU2 reference Velocity:** SU2 utilizes the initialization velocity as a reference; this must be carefully considered when setting up ambient flow conditions. Also, this makes it very difficult to reach the near flow velocity for the farfield condition in external flow.
* **Boundary Proximity:** Far-field boundaries must be sufficiently distant to ensure the jet decays naturally, preventing unphysical backflow that causes oscillations.
* **Stability Tip:** The inclusion of an **upstream section** is vital. It accounts for the "suction" effect created by the jet entrainment. Without this extra buffer, backflow at the inlet often causes divergence or unphysical results.
* **CFL selection** — CFL = 1.0 provides stable convergence for this mesh resolution. For more refined meshes, a modestly higher CFL improved convergence speed, ex. Residuals drop to 1e-8 in 200 iterations with CFL = 100 (with mesh refinement) while it takes more than 1000 iterations with CFL = 1.0

---

## References

- C. Fukushima et al., PIV measurements of a turbulent round jet — experimental dataset used for validation.
