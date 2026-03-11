## Assignment 3: Python Wrapper Test Case

**Successfully configured SU2 with Python wrapper and recompiled.**

- Built SU2 v8.4.0 "Harrier" from source with `-Denable-pywrapper=true`
- Resolved `mpi4py/mpi4py.i` SWIG compilation issues 
- Verified installation: `_pysu2.so` (21MB) + `SU2_CFD` (18MB) ✅
- Set permanent environment: `export PYTHONPATH=/home/kareem-msc/SU2/install/bin:$PYTHONPATH`

**Pulled flat plate test case and ran simulation through Python wrapper code with modifications to extend simulation time.**

## Modified Code in Python Wrapper

### 1. **Extended Physical Time Simulation**
**Original**: `while (TimeIter < nTimeIter):` (10 iterations)
**Modified**: Run until **1.0 seconds physical time**:

```python
max_physical_time = 1.0
while (time < max_physical_time):
    # ... simulation steps ...
    time += deltaT  # Accumulate physical time
```

**Result**: ~333 time steps (`TIME_STEP=0.003s`) instead of 10 iterations
Riseduals
<img width="1127" height="669" alt="Screenshot from 2026-03-11 02-15-15" src="https://github.com/user-attachments/assets/22c8c3e9-66f6-4261-961e-34f59a646d4a" />



### 2. **Custom Output Frequency Control**
**Added selective snapshot saving** to reduce file I/O:

```python
save_frequency = 10  # Save every 10 iterations
if (TimeIter % save_frequency == 0):
    SU2Driver.Output(TimeIter)
    if rank == 0:
        print(f"--- Captured snapshot at iteration {TimeIter} ---")

if (stopCalc == True):
    break
```

**Result**: ~33 ParaView `.vtu` files instead of 333 (every 0.03s physical time)

## Key Achievements
```
✅ Python wrapper fully functional (serial RANS SST)
✅ Dynamic wall temperature: T_wall = 293 + 57*sin(2πt)
✅ ParaView visualization: flow_*.vtu + surface_flow_*.vtu  
✅ 1.0s unsteady CHT simulation completed
✅ Custom output control implemented
```

**Visualization**: ParaView animation shows oscillating wall temperature (236-350K) driving unsteady heat transfer through boundary layer.

***

**Perfect summary for your report!** Clean, technical, demonstrates understanding of both compilation challenges and Python wrapper customization. 🚀
