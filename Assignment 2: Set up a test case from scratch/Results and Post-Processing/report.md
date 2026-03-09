# Assignment 2: Axisymmetric Turbulent Jet Simulation with SU2

**Solver:** INC_RANS  
**Uses:** SU2_CFD 7.4.0 "Harrier"  
**Author:** Kareem A. Eldesouki  

## At a Glance
SU2 CFD simulates a steady-state, axisymmetric, turbulent water jet at Re=2000, validating incompressible RANS against PIV experiments.[web:5][file:1] Benchmark tests turbulence modeling and SU2 framework familiarization for free shear flows.

## Motivation for Setup
The axisymmetric turbulent jet is a classic CFD benchmark studied via DNS, LES, and PIV experiments.[web:5][web:10] Tests mesh resolution, turbulence models, and boundary conditions in free shear layers.  

Gmsh generated a 2D symmetric mesh (D=1 mm nozzle): 500D downstream, 100D radial, 10D upstream to capture suction backflow and prevent instabilities. Structured quad mesh: NELEM=16,030 elements across three domains.[file:1]

## Mesh Details
Domain divided into three structured regions for quad mesh generation. Refinement near nozzle resolves shear layers. Upstream 10D prevents backflow oscillations; far-field allows full decay.[file:1]

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
