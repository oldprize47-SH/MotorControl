# Motor System Identification

This was a two-person digital-control project lasting about eight weeks. We applied sinusoidal inputs to a motor at different frequencies, measured its response and compared first- and second-order models using MATLAB and Simulink.

I worked on the sinusoidal experiments, response analysis and using the fitted model for controller design and target-angle checks. The final measurements used gyroscope-derived angular velocity. Earlier angle-sensor and FFT experiments were a separate stage of the project.

## Recorded response

![Archived motor command voltage and gyro response](assets/recorded-response.png)

This plot contains 4,000 samples from a recorded 0.30 Hz experiment. The upper panel shows command voltage. The lower panel uses the response units stored in the original data because the sensor calibration has not been independently rechecked.

## Analysis

The original `chan.m` script and its two `Plant.slx` simulations ran in MATLAB R2024b on 28 September 2026. The script produced these approximate models:

```text
Gp1(s) = 7656 / (s + 13.12)
Gp2(s) = (1.137e4 s + 5.346e4) / (s^2 + 27.32 s + 84.84)
```

These are reproduced script outputs. The fitting routine reported possible local minima, so they should not be treated as independently validated estimates. Successful replay also does not establish closed-loop hardware performance. No motor was operated during the replay.

The repository now includes [chan.m](Gimbal_board/chan.m), [Plant.slx](Simulink/Plant.slx) and the twelve recorded runs from 0.1 to 1.2 Hz. This package was replayed successfully in MATLAB R2024b on Windows on 28 September 2026. Run `chan` with `Gimbal_board` as the current folder. The script uses Simulink, Control System Toolbox, Signal Processing Toolbox, Optimization Toolbox and Curve Fitting Toolbox; its original Windows paths are retained.

To regenerate the response plot, install NumPy and Matplotlib and run `python plot_recorded_response.py` from the repository root. It writes `portfolio/recorded-response.png` and checks the recorded samples for finite values and increasing time. The acquisition software and hardware setup are not included.
