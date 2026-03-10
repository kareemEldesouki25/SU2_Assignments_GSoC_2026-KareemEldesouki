
# Assignment 2: Axisymmetric Turbulent Jet Simulation with SU2

**Solver:** INC_RANS  
**Version:** SU2_CFD 7.4.0 "Harrier"  
**Author:** Kareem A. Eldesouki  

---

## At a Glance
This report details the steady-state, axisymmetric simulation of a turbulent water jet at **Re = 2000**. The study validates incompressible RANS against Particle Image Velocimetry (PIV) experiments by C. Fukushima et al. This benchmark serves to evaluate turbulence modeling performance in free shear flows within the SU2 framework.


## Motivation for Setup
The axisymmetric turbulent jet is a foundational CFD benchmark. It provides a rigorous test for mesh resolution, turbulence model accuracy, and the influence of boundary conditions in free shear layers. 

The physics involves the interaction between a high-momentum core and the stagnant surrounding fluid. This interaction occurs across a shear layer where large-scale eddies and small-scale turbulence facilitate momentum transfer.

## Geometry and Mesh Details
To optimize computational efficiency while maintaining accuracy, a **2D symmetric configuration** was utilized instead of a full 3D pipe. The structured mesh was generated using **Gmsh**.

### Domain Dimensions
To allow for natural jet development without causing backflow at boundaries, the domain was sized relative to the nozzle diameter ($D = 1$ mm):
* **Downstream:** 500D (to capture the full decay).
* **Radial:** 100D.
* **Upstream:** 10D (to account for suction and prevent backflow instabilities).


The domain was divided into three structured regions for quad generation, resulting in a total of **16,030 elements**.

<img width="763" height="547" alt="Screenshot from 2026-03-10 01-05-20" src="https://github.com/user-attachments/assets/386e0606-e092-4ad5-b1f8-bf1421790490" />


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

## Convergence

While I explored an adaptive CFL strategy—testing across a range of values ($0.1, 1, 2,$ and $10$)—the results showed negligible improvements in either convergence behavior or total computational time. A constant **CFL of 1.0** was maintained without adaptation at the final simulation to ensure a steady path toward convergence. The simulation reached a strict convergence criterion of $10^{-9}$. 

<img width="1123" height="670" alt="Screenshot from 2026-03-09 17-20-09" src="https://github.com/user-attachments/assets/c2078b32-6faa-44ba-ba27-d3d941f1934c" />


## Results and Discussion

Experimental data indicate that the "potential core" of the jet is preserved for approximately **6D**. The SU2 is quite close to these findings:

<img width="1629" height="881" alt="Screenshot from 2026-03-10 02-14-22" src="https://github.com/user-attachments/assets/1ff74b54-ea78-4f27-82c0-3a18a5f3b2af" />

1. **Axial Velocity:** Maintains 90% of its peak value up to **6D**.

<img width="2152" height="1136" alt="Screenshot from 2026-03-10 01-25-53" src="https://github.com/user-attachments/assets/a5e30409-24dd-4b34-a8a4-02e193697941" />

2. **Dissipation:** The flow fully dissipates and merges with the ambient environment by **60D** (The ambient mean velocity was 1.0 m/s -> 0.5 in non-dimensional space.

   
While PIV data includes cross-jet profiles, my simulation focused on axial evolution. Perfect cross-profile mapping would require localized mesh refinement at the nozzle; however, I chose to just validate with normalized axial velocity, as the primary goal of this assignment is to get familiar with the SU2 framework.

## Lessons Learned

* **Reference Velocity:** SU2 utilizes the initialization velocity as a reference; this must be carefully considered when setting up ambient flow conditions. Als,o thimakeske it very difficult to reach near flow velocity for the farfield condition in external flow.
* **Boundary Proximity:** Far-field boundaries must be sufficiently distant to ensure the jet decays naturally, preventing unphysical backflow that causes oscillations.
* **Stability Tip:** The inclusion of an **upstream section** is vital. It accounts for the "suction" effect created by the jet entrainment. Without this extra buffer, backflow at the inlet often causes divergence or unphysical results.

