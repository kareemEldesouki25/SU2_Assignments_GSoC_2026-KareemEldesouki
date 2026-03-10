# Assignment 2: Axisymmetric Turbulent Jet Simulation with SU2

**Solver:** INC_RANS  
**Uses:** SU2_CFD 7.4.0 "Harrier"  
**Author:** Kareem A. Eldesouki  

## At a Glance
SU2 CFD simulates a steady-state, axisymmetric, turbulent water jet at Re=2000, validating incompressible RANS against PIV experiments by C. Fukushima et al Benchmark tests turbulence modeling for free shear flows.

## Motivation for Setup
The axisymmetric turbulent jet is a classic CFD benchmark studied via DNS, LES, and PIV experiments. Tests mesh resolution, turbulence models, and boundary conditions in free shear layers.
The complex physics of a turbulent jet involve the interaction between a high-momentum core and the surrounding relatively stagnant fluid. This interaction occurs across a shear layer where large-scale eddies and small-scale turbulence facilitate the transfer of momentum and scalar quantities.
The goal of this simulation was to model a benchmark problem in fluid mechanics: the turbulent jet. Because this case is heavily documented through High-Fidelity DNS and Experimental PIV (Particle Image Velocimetry) methods, it serves as the perfect "proving ground" for mastering the SU2 framework.

For this study, I referenced the work of C. Fukushima, L. Aanen, and J. Westerweel, specifically their investigation into mixing processes using PIV and LIF.
For simplicity we use the Axisymmetric configuration 

Gmsh generated a 2D symmetric mesh (D=1 mm nozzle): 500D downstream, 100D radial, 10D upstream to capture suction backflow and prevent instabilities. Structured quad mesh: NELEM=16,030 elements across three domains.

## Geometry and Mesh Details
Domain divided into three structured regions for quad mesh generation. Refinement near nozzle resolves shear layers. Upstream 10D prevents backflow oscillations; far-field allows full decay.
I used GMSH to construct a structured mesh. To keep the computational cost low while maintaining accuracy, I opted for a 2D symmetric configuration rather than a full 3D pipe.
Domain Dimensions
To ensure the jet could develop naturally without boundary interference, the domain was sized relative to the nozzle diameter ($D = 1$ mm):Downstream: 500D (to capture the full decay).
Radial: 100D (to allow for entrainment).
Upstream: 10D.

The domain was split into three strategic sections to facilitate a structured grid, resulting in 16,030 quadrilateral elements

## Configuration Summary
```ini
SOLVER= INC_RANS
KIND_TURB_MODEL= SST
AXISYMMETRIC= YES
REF_DIMENSIONALIZATION= DIMENSIONAL
INC_DENSITY_INIT= 998.2
INC_VELOCITY_INIT= (1, 0.0, 0.0)
MU_CONSTANT= 1.002E-3
CFL_NUMBER= 1.0
LINEAR_SOLVER= FGMRES
CONV_NUM_METHOD_FLOW= FDS
MUSCL_FLOW= YES
SLOPE_LIMITER_FLOW= VENKATAKRISHNAN
TIME_DOMAIN= NO

I used water as the working fluid ($\rho = 99.2$, $\mu = 0.001$). To match the experimental Reynolds number ($Re = 2000$), the inlet velocity was set to 2.0 m/s.Turbulence Modeling: Why SST?I chose the Menter SST (Shear Stress Transport) model. While the Spalart-Allmaras (SA) model is a workhorse for external aerodynamics, SST is generally superior for jet flows and capturing the shear layers where the jet meets the stagnant fluid.

Convection Scheme: I favored FDS over ROE for its enhanced stability in low-speed, incompressible regimes.

Linear Solver: I used FGMRES with MUSCL flow enabled. This setup is particularly robust for "stiff" systems where convergence might otherwise stall.

Gradients: Computed via the Green-Gauss method.

## **Convergence**

Simulating low-speed flow requires patience. I kept the CFL number at 1.0 without adaptation to maintain a steady path toward convergence. To ensure the results were truly "baked," I set a strict convergence criterion of $10^{-9}$.

## Results and Discussion
The experimental data indicates that the "potential core" of the jet is preserved for about 6 length scales (6D). My results align well with this:

The axial velocity maintains 90% of its peak up to 6D.

The flow fully dissipates and merges with the ambient environment by 60D.

## Finla comment
While the surrounding fluid converged to a mean velocity of 1.0 (due to the initialization strategy mentioned above), the decay physics remain consistent with the reference paper.

While a finer mesh near the nozzle would be required for a perfect cross-profile mapping, the primary objective—familiarization with the SU2 high-fidelity workflow—was successfully achieved.


## Lessons learned
hard convergence at first
SU2 uses the initialisation velocity as a reference velocity
far field boundary condition must be sufficiently far from the source so as to ensure the the jet decays totally in the surrounding mean flow and ensure there is no back flow that can cause oscilation and divergence in the flow.

Tip for solution stability: I specifically added an upstream section to account for the "suction" effect created by the jet. Without this extra space, backflow at the inlet often causes unphysical oscillations that can crash a simulation.<img width="2152" height="1136" alt="Screenshot from 2026-03-10 01-25-53" src="https://github.com/user-attachments/assets/c2dfedd7-2262-45af-a0dc-4944537efb6b" />
