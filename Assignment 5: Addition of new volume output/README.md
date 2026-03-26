# Assignment 5: Addition of New Volume Output
## Local Speed of Sound in SU2
**Solver:** RANS  
**Version:** SU2_CFD 8.4.0 "Harrier"  
**Author:** Kareem A. Eldesouki  

---

## 1. Objective
This assignment required extending the SU2 CFD solver to output the local speed of sound as a new field in both the volume output (ParaView `.vtu` files) and the screen/history output. I used the incompressible turbulence test case configured in Assignment 1 and adapted it for a compressible jet simulation. The turbulence test case (RANS SST, compressible flow) was then re-run with these new outputs enabled.

---

## 2. Theoretical Background
The local speed of sound in a compressible ideal gas is defined as:

$$a = \sqrt{\frac{\gamma \cdot p}{\rho}} = \sqrt{\gamma \cdot R \cdot T}$$

Where:
* $\gamma$ is the ratio of specific heats.
* $p$ is the static pressure.
* $\rho$ is the density.
* $R$ is the specific gas constant.
* $T$ is the static temperature.

For air at standard conditions (~300°K), this evaluates to approximately **340 m/s**, which is confirmed by the simulation results. The SU2 compressible flow solver already computes this quantity internally at every node.

In SU2, the speed of sound is typically calculated within the fluid model classes. For a compressible RANS simulation, this is handled in `src/models/fluid_model.cpp` (or specifically `CIdGas::GetSoundSpeed` for ideal gases).

---

## 3. Source Code Modifications

### 3.1 File Modified
The primary file modified was: `SU2_CFD/src/output/CFlowCompOutput.cpp`. This file handles output specifically for compressible flow solvers.

| Class | File | Role |
| :--- | :--- | :--- |
| `COutput` | `COutput.cpp` | Generic output infrastructure |
| `CFlowOutput` | `CFlowOutput.cpp` | Shared base for all flow solvers |
| **`CFlowCompOutput`** | **`CFlowCompOutput.cpp`** | **Compressible RANS/NS/Euler — MODIFIED** |
| `CFlowIncOutput` | `CFlowIncOutput.cpp` | Incompressible solver (not modified) |

### 3.2 Edit 1 — Volume Output Registration
In `void CFlowCompOutput::SetVolumeOutputFields()`, the field was registered under the `PRIMITIVE` group (line ~240):

```cpp
// Existing Mach number field (reference):
AddVolumeOutput("MACH", "Mach", "PRIMITIVE", "Mach number");

// ADDED: Speed of sound volume field
AddVolumeOutput("SOUND_SPEED", "Sound_Speed", "PRIMITIVE", "Local speed of sound");
```

### 3.3 Edit 2 — Volume Output Value Loading
In `void CFlowCompOutput::LoadVolumeData`, the per-node speed of sound value is loaded :

```cpp
// Existing Mach loading (reference):
SetVolumeOutputValue("MACH", iPoint, sqrt(Node_Flow->GetVelocity2(iPoint)) / Node_Flow->GetSoundSpeed(iPoint));

// ADDED: Load pre-computed sound speed at each node
SetVolumeOutputValue("SOUND_SPEED", iPoint, Node_Flow->GetSoundSpeed(iPoint));
```

### 3.4 Edit 3 — History Output Registration
In `void CFlowCompOutput::SetHistoryOutputFields()`, the new history/screen column was registered (line ~145):

```cpp
AddHistoryOutput(
    "SOUND_SPEED",
    "Avg_SoundSpeed",
    ScreenOutputFormat::SCIENTIFIC,
    "FLOW_COEFF",
    "Average local speed of sound in the domain",
    HistoryFieldType::COEFFICIENT
);
```

### 3.5 Edit 4 — History Output Value Computation
In `void CFlowCompOutput::LoadHistoryData()`, a domain-averaged speed of sound is computed with MPI reduction (line ~490):

```cpp
su2double AvgSoundSpeed = 0.0;
  unsigned long nPointDomain = geometry->GetnPointDomain();
  for (unsigned long iPoint = 0; iPoint < nPointDomain; iPoint++) {
      AvgSoundSpeed += solver[FLOW_SOL]->GetNodes()->GetSoundSpeed(iPoint);
  }
  SU2_MPI::Allreduce(&AvgSoundSpeed, &AvgSoundSpeed, 1, MPI_DOUBLE, MPI_SUM, SU2_MPI::GetComm());
  unsigned long nPointGlobal = geometry->GetGlobal_nPointDomain();
  SetHistoryOutputValue("SOUND_SPEED", AvgSoundSpeed / nPointGlobal);
```

---

## 4. Build Procedure
After modifying the source code, SU2 needs to be recompiled using Meson and Ninja:

```bash
cd ~/SU2
# 1. Remove the old build directory to avoid stale object conflicts
rm -rf build
# 2. Reconfigure the project with your desired settings
python3 meson.py build --prefix=$HOME/SU2/install -Dwith-mpi=disabled
# 3. Compile the new source code
ninja -C build
# 4. Install the new binary to your local folder
ninja -C build install
```

---

## 5. Configuration File Settings
To add the local sound speed to our screen output, the following settings were modified in `Sym_jet_Comp.cfg`:

```ini
% Screen output columns
SCREEN_OUTPUT= INNER_ITER, RMS_DENSITY, RMS_MOMENTUM-X, RMS_ENERGY, SOUND_SPEED

% Volume output groups for ParaView
VOLUME_OUTPUT= PRIMITIVE

% History file output groups
HISTORY_OUTPUT= ITER, RMS_RES, FLOW_COEFF
```

I also modified the boundary conditions for a compressible jet:
**Pressure Ratio ($P_t / P_{static}$):** Approximately **1.524**
```
MARKER_OUTLET= ( outlet, 101325, farfield, 101325 )
INLET_TYPE= TOTAL_CONDITIONS
MARKER_INLET= ( inlet, 300, 154490, 1, 0, 0 )
```

---
## 6. History Output Results
The new `Avg_SoundSpeed` column appeared in the screen output:
<img width="770" height="465" alt="image" src="https://github.com/user-attachments/assets/3fbece88-432a-4d2b-9211-abe96f5685af" />

The domain-averaged speed of sound converges to **~340 m/s**, consistent with standard air conditions.

---

## 7. Volume Output (ParaView)
To visualize the spatial distribution:
* Open the `.vtu` file in ParaView.
* Select `Sound_Speed` from the field list.

The simulation reveals that the jet core possesses a **lower speed of sound** than the ambient medium. This is consistent with isentropic flow theory: as the fluid accelerates from the inlet stagnation state (`INLET_TYPE= TOTAL_CONDITIONS` $T_t = 300\text{ K}$ ) to the high-velocity jet plume, internal energy is converted into kinetic energy. 

This results in a decrease in **static temperature** ($T$) within the jet. Since the speed of sound is defined as $a = \sqrt{\gamma R T}$, the cooler, fast-moving jet core naturally exhibits a lower acoustic velocity compared to the stagnant ambient air.
<div align="center">
<br>
Figure 1: Zoomed-in local speed of sound contour.
<br>
<img width="602" height="204" alt="sss" src="https://github.com/user-attachments/assets/f2ad414c-82f1-496d-b8cf-e629ba17af4e" />
<br>
<br>
Figure 2: Local speed of sound contour (Sound_Speed field) over the turbulent jet domain.
<br>
<img width="602" height="204" alt="sound" src="https://github.com/user-attachments/assets/2d3e0237-1901-44ef-afbf-1f48f2a8cfc5" />
<br>
<br>
Figure 3: Velocity field over the turbulent jet domain.
<br>
<img width="602" height="204" alt="velocity" src="https://github.com/user-attachments/assets/76424508-e45e-4365-a15d-240e2f095645" />
<br>
</div>
---


## 8. Lessons Learned

### 8.1 Lessons related to SU2 Output Architecture

- The solver computes quantities like sound speed internally at every node, but each field must be explicitly registered in `SetVolumeOutputFields()` and loaded in `LoadVolumeData()` before it appears in any output.
- The output system is solver-specific — `CFlowCompOutput` handles compressible cases separately from `CFlowIncOutput`, so it matters which class you are editing. Once I understood that structure, the four required edits were straightforward to locate.

### 8.2 What I learned to get a converged compressible simulation setting
The more time-consuming part of this assignment was not the output implementation — it was getting the compressible jet case to converge, and finally i was able to get the proper configuration summarized as below.
- **Boundary condition type matters more than expected.** Trying different inlet types — velocity inlet and mass flow rate — led to significant instability. The stable configuration required `INLET_TYPE= TOTAL_CONDITIONS` paired with the correct initialisation strategy described below.
- **Freestream initialisation.** My initial approach was to set `MACH_NUMBER= 0.001` to define the freestream state. This works for incompressible cases but breaks down in compressible simulations — at such a low Mach number the solver initialises a near-zero velocity field, which immediately causes instability. The fix was `INIT_OPTION= TD_CONDITIONS` with explicit static P = 101,325 Pa and T = 300 K, which lets the solver construct a consistent initial field from first principles. In the final working configuration `MACH_NUMBER` is set to `1E-9` — effectively a dummy value since `TD_CONDITIONS` takes over the initialisation entirely.
- **Convective scheme.** For this jet case, ROE + MUSCL with no limiter was unstable in the high velocity regions of the jet core. Reading into both schemes, the key difference is that JST carries built-in artificial dissipation which stabilises the solution across the wide Mach range present in a jet — from the stagnant ambient all the way through the accelerating core — whereas ROE with no limiter has no such mechanism. Switching to JST gave a stable solution.
