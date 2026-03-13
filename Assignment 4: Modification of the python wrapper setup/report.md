## Problem definition 
Enable a spatially varying wall temperature for a steady-state compressible turbulent flat plate testcase in SU2 using python wrapper

### Thermal Boundary Condition
A linear temperature ramp was implemented using the SU2 Python wrapper. The temperature varies from $293.15 \text{K}$ at the inlet to $350 \text{K}$ at the outlet ($x = 0.035 \text{m}$), governed by:
$$T_{wall}(x) = 293.15 + 56.85 \cdot \left(\frac{x}{0.035}\right)$$

This was achieved by extracting the marker coordinates using the `.MarkerCoordinates` method and mapping the local $x$-position to the target temperature at every iteration.

<img src="Results/Temperature%20variation.png" alt="Fig.1 Temperature Variation" width="50%">
## 2. Simulation Results
The simulation reached the convergence criteria at iteration **388**. The density residual successfully reached the target order of magnitude of $10^{-6}$.

### Temperature Distribution
<img src="Results/Temperature.png" alt="Fig.1 Temperature" width="50%">

### Final Convergence State
| Variable | Header | Final Residual ($\log_{10}$) |
| :--- | :--- | :---: |
| **Density** | `rms[Rho]` | **-6.00** |
| **Momentum (u)** | `rms[RhoU]` | -3.86 |
| **Momentum (v)** | `rms[RhoV]` | -3.89 |
| **Energy** | `rms[RhoE]` | -1.67 |
| **Turb. Kinetic Energy** | `rms[k]` | -3.47 |
| **Spec. Dissipation** | `rms[w]` | +0.45 |

### Convergence History
The plot below shows the decay of residuals. Note that while Density reached the target, the turbulence and energy residuals stabilized at higher values.

![Flow Residuals](Results/Riseduals%20Assignment%204.png)


### Velocity Distribution
![Velocity Distribution](Results/Velocity.png)

## 3. Appendix: Python Wrapper Implementation
The following implementation extracts the marker coordinates and injects the custom temperature field into the solver at each iteration step.

# Main iteration loop
  while (iIter < max_iterations):
    # 1. Preprocess the current iteration
    SU2Driver.Preprocess(iIter)

    # 2. Get the ENTIRE coordinate matrix ONCE per iteration
    all_coords = SU2Driver.MarkerCoordinates(CHTMarkerID)

    # 3. Loop through every vertex to set temperature
    for iVertex in range(nVertex_CHTMarker):
        
        # Access the x-coordinate from the 'all_coords' matrix we just got
        # Row = iVertex, Column = 0 (x-coordinate)
        x_pos = all_coords.Get(iVertex, 0)
        
        # Spatial function: Linear ramp (293.15K to 350K over 0.035m)
        L_plate = 0.035
        T_inlet = 293.15
        T_outlet = 350.0
        WallTemp_Spatial = T_inlet + (T_outlet - T_inlet) * (x_pos / L_plate)
        
        # Apply local temperature
        SU2Driver.SetMarkerCustomTemperature(CHTMarkerID, iVertex, WallTemp_Spatial)

    # 4. Update boundary conditions and run solver
    SU2Driver.BoundaryConditionsUpdate()
    SU2Driver.Run()
    SU2Driver.Postprocess()
    SU2Driver.Update()

    # 5. Monitor convergence and handle output
    stopCalc = SU2Driver.Monitor(iIter)
    
    if (iIter % 50 == 0):
        SU2Driver.Output(iIter)
        if rank == 0:
            print(f"--- Iteration {iIter}: Solution snapshot saved ---")

    if (stopCalc == True):
        if rank == 0: print("Convergence reached!")
        break
    
    iIter += 1
    '''

