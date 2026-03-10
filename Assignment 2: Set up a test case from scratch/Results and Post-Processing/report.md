
# Assignment 2: Axisymmetric Turbulent Jet Simulation with SU2

**Solver:** INC_RANS  
**Version:** SU2_CFD 7.4.0 "Harrier"  
**Author:** Kareem A. Eldesouki  

---

## At a Glance
This report details the steady-state, axisymmetric simulation of a turbulent water jet at **Re = 2000**. The study validates incompressible RANS against Particle Image Velocimetry (PIV) experiments by C. Fukushima et al. This benchmark serves to evaluate turbulence modeling performance in free shear flows within the SU2 framework.



## Motivation for Setup
The axisymmetric turbulent jet is a foundational CFD benchmark. It provides a rigorous test for mesh resolution, turbulence model accuracy, and the influence of boundary conditions in free shear layers. 

The physics involve the interaction between a high-momentum core and the stagnant surrounding fluid. This interaction occurs across a shear layer where large-scale eddies and small-scale turbulence facilitate momentum transfer. By referencing the work of C. Fukushima, L. Aanen, and J. Westerweel, this case acts as a "proving ground" for mastering high-fidelity physics simulations in SU2.

## Geometry and Mesh Details
To optimize computational efficiency while maintaining accuracy, a **2D symmetric configuration** was utilized instead of a full 3D pipe. The structured mesh was generated using **Gmsh**.

### Domain Dimensions
To allow for natural jet development and entrainment without boundary interference, the domain was sized relative to the nozzle diameter ($D = 1$ mm):
* **Downstream:** 500D (to capture the full decay).
* **Radial:** 100D (to allow for sufficient entrainment).
* **Upstream:** 10D (to account for suction and prevent backflow instabilities).

The domain was divided into three structured regions for quad generation, resulting in a total of **16,030 elements**.

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

### Technical Rationale

* **Fluid Properties:** Water was used as the working fluid ($\rho = 998.2$ kg/m³, $\mu = 0.001$ Pa·s). To match the experimental $Re = 2000$, the inlet velocity was set to 2.0 m/s.
* **Turbulence Modeling (SST):** The Menter Shear Stress Transport (SST) model was selected over Spalart-Allmaras (SA) for its superior ability to capture shear layer development where the jet meets stagnant fluid.
* **Numerical Schemes:** **FDS** was favored over ROE for enhanced stability in low-speed, incompressible regimes. **FGMRES** with **MUSCL** was utilized to handle the "stiff" nature of the system.
* **Gradients:** Computed via the Green-Gauss method.

## Convergence

Simulating low-speed flow requires a conservative approach. A constant **CFL of 1.0** was maintained without adaptation to ensure a steady path toward convergence. The simulation reached a strict convergence criterion of $10^{-9}$.

## Results and Discussion

Experimental data indicates that the "potential core" of the jet is preserved for approximately **6D**. The SU2 results align well with these findings:

1. **Axial Velocity:** Maintains 90% of its peak value up to **6D**.
2. **Dissipation:** The flow fully dissipates and merges with the ambient environment by **60D**.

While a finer mesh near the nozzle would be required for a perfect cross-profile mapping, the primary objective—familiarization with the SU2 high-fidelity workflow—was successfully achieved.

## Lessons Learned

* **Reference Velocity:** SU2 utilizes the initialization velocity as a reference; this must be carefully considered when setting up ambient flow conditions.
* **Boundary Proximity:** Far-field boundaries must be sufficiently distant to ensure the jet decays naturally, preventing unphysical backflow that causes oscillations.
* **Stability Tip:** The inclusion of an **upstream section** is vital. It accounts for the "suction" effect created by the jet entrainment. Without this extra buffer, backflow at the inlet often causes divergence or unphysical results.
