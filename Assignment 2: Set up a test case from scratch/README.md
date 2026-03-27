
# Assignment 2: Axisymmetric Turbulent Jet Simulation with SU2

**Solver:** INC_RANS  
**Version:** SU2_CFD 8.4.0 "Harrier"  
**Author:** Kareem A. Eldesouki  

---

## At a Glance
This report details the steady-state, axisymmetric simulation of a turbulent water jet at **Re = 2000**. The study validates incompressible RANS against Particle Image Velocimetry (PIV) experiments by C. Fukushima et al. This benchmark serves to evaluate turbulence modeling performance in free shear flows within the SU2 framework.

<img width="2106" height="1114" alt="image" src="https://github.com/user-attachments/assets/f70b9a4c-38b5-4c91-a8fa-d82e93878a56" />


## Motivation for Setup
The axisymmetric turbulent jet is a foundational CFD benchmark. It provides a rigorous test for mesh resolution, turbulence model accuracy, and the influence of boundary conditions in free shear layers. 

The physics involves the interaction between a high-momentum core and the stagnant surrounding fluid. This interaction occurs across a shear layer where large-scale eddies and small-scale turbulence facilitate momentum transfer.

## Geometry and Mesh Details
To optimize computational efficiency while maintaining accuracy, a **2D symmetric configuration** was utilized instead of a full 3D pipe. The structured mesh was generated using **Gmsh**.

### Domain Dimensions
To allow for natural jet development without causing backflow at boundaries, the domain was sized relative to the nozzle diameter ($D = 1$ mm):
* **Downstream:** 500D -1100D (to capture the full decay).
* **Radial:** 100D-200D.
* **Upstream:** 10D (to account for suction and prevent backflow instabilities).


The domain was divided into three structured regions for quad generation, generated with Gmsh

<img width="363" height="547" alt="Screenshot from 2026-03-10 01-05-20" src="https://github.com/user-attachments/assets/386e0606-e092-4ad5-b1f8-bf1421790490" />

<img width="602" alt="mesh ref" src="https://github.com/user-attachments/assets/aca321ab-4f8d-4afb-8aa6-151985cddbe5" />

<img width="1002" height="209" alt="mesh" src="https://github.com/user-attachments/assets/7f28ce84-f6d4-4f54-80d4-a798eb2ee7e6" />



## Configuration Summary
```ini
% --- SOLVER SETTINGS ---
SOLVER= INC_RANS
KIND_TURB_MODEL= SST
AXISYMMETRIC= YES
REF_DIMENSIONALIZATION= DIMENSIONAL

% --- INITIAL CONDITIONS ---
INC_DENSITY_INIT= 998.2
INC_VELOCITY_INIT= (1.0, 0.0, 0.0)
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

As we are aiming to get steady-state averaged values, I used the SST RANS model for turbulence modeling for its superiority in jet flow simulation.
### 

* **Fluid Properties:** Water was used as the working fluid ($\rho = 998.2$ kg/m³, $\mu = 0.001$ Pa·s). To match the experimental $Re = 2000$, the inlet velocity was set to 2.0 m/s.
* **Turbulence Modeling (SST):** The Menter Shear Stress Transport (SST) model was selected over Spalart-Allmaras (SA) for its superior ability to capture shear layer development as our simulation experiences a significant shear at the interface between the jet and the surrounding, where the jet meets stagnant fluid.
* **Numerical Schemes:** **FDS** was favored over ROE for enhanced stability in low-speed, incompressible regimes. **FGMRES** with **MUSCL** was utilized to handle the "stiff" nature of the system.
* **Gradients:** Computed via the Green-Gauss method.
## Boundary conditions
```
MARKER_ISOTHERMAL= ( wall, 288.0)
MARKER_SYM = ( symmetric )
MARKER_INTERNAL= ( internal)
INC_INLET_TYPE= VELOCITY_INLET
MARKER_INLET= ( inlet, 288.0, 2.0, 1.0, 0.0, 0.0 )
INC_OUTLET_TYPE= PRESSURE_OUTLET 
MARKER_OUTLET= ( outlet, 0.0)
MARKER_MONITORING= ( wall )
```


## Convergence

While I explored an adaptive CFL strategy—testing across a range of values ($0.1, 1, 2,$ and $10$)—the results showed negligible improvements in either convergence behavior or total computational time. A constant **CFL of 1.0** was maintained without adaptation at the final simulation to ensure a steady path toward convergence. The simulation reached a strict convergence criterion of $10^{-7}$. 

<img width="1291" height="990" alt="image" src="https://github.com/user-attachments/assets/85532467-b9cd-46d4-8f16-465b0e2097e7" />

## Results and Validation
**Axial Decay and Potential Core**
The simulation correctly identifies a potential core extending to approximately 6D, where the centerline velocity remains at 90% of the inlet value ($2.0$ m/s)

<img width="1629" height="881" alt="Screenshot from 2026-03-10 02-14-22" src="https://github.com/user-attachments/assets/1ff74b54-ea78-4f27-82c0-3a18a5f3b2af" />

1. **Axial Velocity:** Maintains 90% of its peak value up to **6D**.

<img width="2152" height="1136" alt="Screenshot from 2026-03-10 01-25-53" src="https://github.com/user-attachments/assets/a5e30409-24dd-4b34-a8a4-02e193697941" />

2. **Dissipation:** The flow fully dissipates and merges with the ambient environment by **60D** (The ambient mean velocity was 1.0 m/s -> 0.5 in non-dimensional space.

**Self-Similarity & Co-flow Impact**

The jet was analyzed using the velocity excess ratio: $\frac{U_j - U_a}{U_c - U_a}$.

**Verification:** The linear trend in the far-field ($R^2 \approx 0.99$) confirms that the solver is correctly capturing the mathematical self-similarity of the flow.Validation: Compared to the Fukushima study ($U_a = 0$), the current co-flow ($U_a = 1.0$ m/s) significantly reduces the shear gradient. This results in a much slower decay constant ($B \approx 113$) and a shifted virtual origin ($x_0/d \approx -173$).

<img width="1842" height="1165" alt="Figure_1" src="https://github.com/user-attachments/assets/9754ee57-f839-4817-9b80-e47c8a8dcc44" />

**Self-Similarity and Radial Profile Validation**

According to the reference study by Fukushima et al., a turbulent jet typically achieves a self-similar state in the region $30 \le x/D \le 130$. In this regime, the radial velocity profiles, when normalized by the local centerline velocity ($U_c$), should collapse onto a single universal curve when plotted against the non-dimensional similarity variable, $\eta$:$$\eta = \frac{r}{x - x_0}$$Where $r$ is the radial distance from the centerline, $x$ is the axial distance, and $x_0$ is the virtual origin.

<img width="2054" height="1202" alt="Screenshot from 2026-03-27 20-40-19" src="https://github.com/user-attachments/assets/141d7dc5-2e34-49f5-90f6-91a60258b9cb" />

As illustrated in the provided similarity plot, the profiles for $x/D = 90, 100, 130,$ and $160$ demonstrate a strong qualitative collapse, indicating that the solver has captured the transition into the self-preserving region. However, the profile at $x/D = 60$ appears significantly broader and "flattened" compared to the downstream locations.Physically, the experiment suggests $x/D = 60$ should already be fully self-similar. The observed discrepancy—where the $60D$ profile still resembles the potential core or early transition region—suggests that the simulated jet is spreading more slowly than the physical experiment. This delay in self-similarity is likely a combined result of the 1 m/s of the surrounding fluid domain and the potential need for higher-order numerical schemes or more sensitive turbulence modeling to capture the early-stage mixing at $Re = 2000$.

## Modified Meshing and verifications
<img width="1102" height="469" alt="Screenshot from 2026-03-25 12-36-39" src="https://github.com/user-attachments/assets/ac5dc407-d9d9-4729-8a1a-7ed741cac1a4" />
Convergence history of the modified mesh refinement around the jet diameter. Note the oscilating convergence at the end where the riseduals oscilates withing a certain range, this was found to be due to the need for more downstream domain for example, the used case was the downstream was 400 times the diamter, however for the following case the downstream lengthwas increased to 1100 times diameter and also the lateral domain was doubled to allow for pressure dissipation and avoid any adverse pressures at the boundaries.

<img width="1773" height="1144" alt="image" src="https://github.com/user-attachments/assets/5bb31971-7cab-4b41-a926-3ac9f0e65e9f" />


## Lessons Learned

* **Reference Velocity:** SU2 utilizes the initialization velocity as a reference; this must be carefully considered when setting up ambient flow conditions. Also, this makes it very difficult to reach the near flow velocity for the farfield condition in external flow.
* **Boundary Proximity:** Far-field boundaries must be sufficiently distant to ensure the jet decays naturally, preventing unphysical backflow that causes oscillations.
* **Stability Tip:** The inclusion of an **upstream section** is vital. It accounts for the "suction" effect created by the jet entrainment. Without this extra buffer, backflow at the inlet often causes divergence or unphysical results.
* * **CFL Courant number:** for a refined mesh, the simulation is more stable at higher CFL numbers

