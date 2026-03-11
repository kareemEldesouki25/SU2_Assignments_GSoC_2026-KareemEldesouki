## Assignment 3: Python Wrapper Test Case

![Flat Plate](https://github.com/user-attachments/assets/52f95353-fc62-4bd0-9223-4546da7eab5e)
*GIF.1: Temperature contours animation oflver 1.0 second.*

**Successfully configured SU2 with Python wrapper and recompiled.**

- Built SU2 v8.4.0 "Harrier" from source with `-Denable-pywrapper=true`
- Resolved `mpi4py/mpi4py.i` SWIG compilation issues 

**Pulled flat plate test case and simulated Python wrapper code with modifications to extend simulation time.**

Using the ready-to-run Flat plate test case and the Python wrapper file with little modifications as follows:

### 1. **Extended Physical Time Simulation**
By refining the iteration loop to stop when physical time reaches 1 second, rather than terminating after some number of iterations

**Original**: `while (TimeIter < nTimeIter):` (10 iterations)
**Modified**: Run until **1.0 seconds physical time**:

```python
max_physical_time = 1.0
while (time < max_physical_time):
    # ... simulation steps ...
    time += deltaT  # Accumulate physical time
```

Riseduals
<img width="1127" height="669" alt="Screenshot from 2026-03-11 02-15-15" src="https://github.com/user-attachments/assets/22c8c3e9-66f6-4261-961e-34f59a646d4a" />



### 2. **Change output write frequency in the Python code**

```python
save_frequency = 10  # Save every 10 iterations
if (TimeIter % save_frequency == 0):
    SU2Driver.Output(TimeIter)
```
