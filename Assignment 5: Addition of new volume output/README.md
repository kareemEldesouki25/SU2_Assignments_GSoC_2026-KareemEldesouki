Here is the complete Markdown code for your assignment report. I have formatted the equations in LaTeX, structured the code blocks for C++ and Bash, and converted your tables into clean Markdown format.

```markdown
# Assignment 5: Addition of New Volume Output
## Local Speed of Sound in SU2
**Computational Fluid Dynamics | SU2 Solver Modification**

---

## 1. Objective
This assignment required extending the SU2 CFD solver to output the local speed of sound as a new field in both the volume output (ParaView `.vtu` files) and the screen/history output. The turbulent test case (RANS SST, compressible flow) was then re-run with these new outputs enabled.

## 2. Theoretical Background
The local speed of sound in a compressible ideal gas is defined as:

$$a = \sqrt{\frac{\gamma \cdot p}{\rho}} = \sqrt{\gamma \cdot R \cdot T}$$

Where:
* $\gamma$ is the ratio of specific heats.
* $p$ is the static pressure.
* $\rho$ is the density.
* $R$ is the specific gas constant.
* $T$ is the static temperature.

For air at standard conditions (~15°C), this evaluates to approximately **340 m/s**, which is confirmed by the simulation results. The SU2 compressible flow solver already computes this quantity internally at every node. The task was to expose this pre-computed value through the output infrastructure.

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
// Existing Mach number field (reference):
AddVolumeOutput("MACH", "Mach", "PRIMITIVE", "Mach number");

// NEW: Speed of sound volume field
AddVolumeOutput("SOUND_SPEED", "Sound_Speed", "PRIMITIVE", "Local speed of sound");
```

### 3.3 Edit 2 — Volume Output Value Loading
In `LoadVolumeData()`, the per-node speed of sound value is loaded (line ~340):

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
The following settings were modified in `Sym_jet.cfg`:

```ini
% Screen output columns
SCREEN_OUTPUT= INNER_ITER, RMS_DENSITY, RMS_MOMENTUM-X, RMS_ENERGY, SOUND_SPEED

% Volume output groups for ParaView
VOLUME_OUTPUT= PRIMITIVE

% History file output groups
HISTORY_OUTPUT= ITER, RMS_RES, FLOW_COEFF
```

---

## 5. Build Procedure
SU2 was recompiled using Meson and Ninja with MPI disabled to resolve system compatibility issues:

```bash
cd ~/SU2
rm -rf build
python3 meson.py build --prefix=$HOME/SU2/install -Dwith-mpi=disabled
ninja -C build
ninja -C build install
```

---

## 6. History Output Results
The new `Avg_SoundSpeed` column appeared in the screen output:

| Inner_Iter | rms[Rho] | rms[RhoU] | rms[RhoE] | Avg_SoundSpeed (m/s) |
| :--- | :--- | :--- | :--- | :--- |
| 0 | -1.3552 | 0.8273 | 4.2393 | 3.4048e+02 |
| 1 | -1.4113 | 0.7975 | 4.2091 | 3.4046e+02 |
| 2 | -1.4803 | 0.7535 | 4.1618 | 3.4043e+02 |
| 3 | -1.5712 | 0.6925 | 4.0877 | 3.4039e+02 |
| 4 | -1.6868 | 0.6203 | 3.9779 | 3.4035e+02 |
| 5 | -1.7532 | 0.5717 | 3.8934 | 3.4031e+02 |
| 6 | -1.7393 | 0.5569 | 3.8999 | 3.4029e+02 |

The domain-averaged speed of sound converges to **~340.3 m/s**, consistent with standard air conditions.

---

## 7. Volume Output (ParaView)
To visualize the spatial distribution:
* Open the `.vtu` file in ParaView.
* Select `Sound_Speed` from the field list.
* Apply a "Cool to Warm" color map.

Regions of higher temperature (near the jet core) show higher speed of sound values ($a \propto \sqrt{T}$), while the ambient region shows the reference value.



**Figure 1:** Local speed of sound contour (Sound_Speed field) over the turbulent jet domain.

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

**End of Report**
```
## 1. Objective
It is required to extend the SU2 CFD solver to output the local speed of sound as a new field in both the volume output (ParaView .vtu files) and the screen/history output. The turbulent test case for a symmetric jet was re-configured to simulate a compressible jet and so to be able to calculate local speed for sound as it is a function in (RANS SST, compressible flow) was then re-run with these new outputs enabled.

The local speed of sound is not a single constant, but a thermodynamic property of a medium that depends on the state of that medium (specifically, pressure and density). The general formula for the speed of sound is 
<img width="134" alt="image" src="https://github.com/user-attachments/assets/3e19e8f3-099c-46ce-948c-1935d2190226" />

<img width="301" height="110" alt="image" src="https://github.com/user-attachments/assets/0ce6884d-82e1-4448-a4cf-8869934faec7" />

which represents the rate of change of pressure with respect to density at constant entropy 

## Implementation source code

## Rebuild

## Cmpressible configuration


Add the speed of sound to the screen outputs
% --- SCREEN AND HISTORY OUTPUT ---
SCREEN_OUTPUT= (INNER_ITER, RMS_DENSITY, RMS_MOMENTUM-X, RMS_ENERGY, DRAG, LIFT, SOUND_SPEED)
HISTORY_OUTPUT= (ITER, RMS_RES, DRAG, LIFT, SOUND_SPEED)

## Meshing

## Results and graphs

## Lessons learned about source code structure

## Lessons learned from compressible solver
