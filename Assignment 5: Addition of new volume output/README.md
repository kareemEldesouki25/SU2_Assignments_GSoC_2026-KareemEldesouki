# Assignment 5: Addition of New Volume Output
## Local Speed of Sound in SU2

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

For air at standard conditions (~15°C), this evaluates to approximately **340 m/s**, which is confirmed by the simulation results. The SU2 compressible flow solver already computes this quantity internally at every node.

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
In `SetVolumeOutputFields()`, the field was registered under the `PRIMITIVE` group (line ~240):

```cpp
iside the void `CFlowCompOutput::SetVolumeOutputFields(CConfig *config){}` finction add the volume field for the local speed of sound

// Existing Mach number field (reference):
AddVolumeOutput("MACH", "Mach", "PRIMITIVE", "Mach number");

// NEW: Speed of sound volume field
AddVolumeOutput("SOUND_SPEED", "Sound_Speed", "PRIMITIVE", "Local speed of sound");
```

### 3.3 Edit 2 — Volume Output Value Loading
In `LoadVolumeData()`, the per-node speed of sound value is loaded :
`void CFlowCompOutput::LoadVolumeData(CConfig *config, CGeometry *geometry, CSolver **solver, unsigned long iPoint)`

```cpp
// Existing Mach loading (reference):
SetVolumeOutputValue("MACH", iPoint, sqrt(Node_Flow->GetVelocity2(iPoint)) / Node_Flow->GetSoundSpeed(iPoint));

// NEW: Load pre-computed sound speed at each node
SetVolumeOutputValue("SOUND_SPEED", iPoint, Node_Flow->GetSoundSpeed(iPoint));
```

### 3.4 Edit 3 — History Output Registration
In `SetHistoryOutputFields()`, the new history/screen column was registered (line ~145):

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
In `LoadHistoryData()`, a domain-averaged speed of sound is computed with MPI reduction (line ~490):

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

## 4. Configuration File Settings
To add the local sound speed to our screen output, the following settings were modified in `Sym_jet_Comp.cfg`:

```ini
% Screen output columns
SCREEN_OUTPUT= INNER_ITER, RMS_DENSITY, RMS_MOMENTUM-X, RMS_ENERGY, SOUND_SPEED

% Volume output groups for ParaView
VOLUME_OUTPUT= PRIMITIVE

% History file output groups
HISTORY_OUTPUT= ITER, RMS_RES, FLOW_COEFF
```

I modified the boundary conditions and meshing as follows:
The pressure ratio is 
```
MARKER_OUTLET= ( outlet, 101325, farfield, 101325 )
INLET_TYPE= TOTAL_CONDITIONS
MARKER_INLET= ( inlet, 300, 154490, 1, 0, 0 )
```

---

## 5. Build Procedure
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

## 6. History Output Results
The new `Avg_SoundSpeed` column appeared in the screen output:
<img width="770" height="465" alt="image" src="https://github.com/user-attachments/assets/3fbece88-432a-4d2b-9211-abe96f5685af" />

The domain-averaged speed of sound converges to **~340 m/s**, consistent with standard air conditions.

---

## 7. Volume Output (ParaView)
To visualize the spatial distribution:
* Open the `.vtu` file in ParaView.
* Select `Sound_Speed` from the field list.
* Apply a "Cool to Warm" color map.

Regions of higher temperature (near the jet core) show higher speed of sound values ($a \propto \sqrt{T}$), while the ambient region shows the reference value.

**Figure 1:** Local speed of sound contour (Sound_Speed field) over the turbulent jet domain.
<img width="602" height="204" alt="sound" src="https://github.com/user-attachments/assets/2d3e0237-1901-44ef-afbf-1f48f2a8cfc5" />

**Figure 2:** Velocity filed over the turbulent jet domain.

---

## 8. Summary of Changes

| File | Function | Change Made |
| :--- | :--- | :--- |
| `CFlowCompOutput.cpp` | `SetVolumeOutputFields()` | Added `SOUND_SPEED` under `PRIMITIVE` group |
| `CFlowCompOutput.cpp` | `LoadVolumeData()` | Mapped `GetSoundSpeed(iPoint)` to volume output |
| `CFlowCompOutput.cpp` | `SetHistoryOutputFields()` | Registered `SOUND_SPEED` for history/screen |
| `CFlowCompOutput.cpp` | `LoadHistoryData()` | Added domain-average calculation with MPI |
| `Sym_jet.cfg` | `SCREEN_OUTPUT` | Included `SOUND_SPEED` in display |
| `Sym_jet.cfg` | `VOLUME_OUTPUT` | Set to `PRIMITIVE` to include new field |

---

**Lessons learned**

1- Implementing a new output field in SU2 involves bridging the gap between the physics kernels (where the math happens) and the output classes (where data is formatted for ParaView). Not all variables are displayed in the output
2- Learned about functions in the CFlowOutput class
