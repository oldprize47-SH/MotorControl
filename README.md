# Motor System Identification

This digital-control project measured a motor's response to sinusoidal inputs and used the recorded data to compare first- and second-order models in MATLAB and Simulink. The project lasted about eight weeks and connected measurement, model identification and controller study.

## Project goal

Measure how a motor responds to commands and identify models that can support controller design.

![Project goal: motor-system-identification](docs/goals/project-focus-v1.png)

AI-generated concept illustration. Device appearance, interface layout and example graphics are illustrative, not project photographs or measured results.

## Where it could be used

This measurement-and-model workflow can support laboratory characterisation of a motor-driven mechanism before controller tuning. Comparing an identified model with measured response can help decide whether the model captures the behaviour needed for a control experiment. Applying it to another actuator would require new measurements and calibration; the saved experiment does not establish performance for a different drive.

## At a glance

![Motor measurement and identification](docs/flowcharts/motor.png)

Overview reconstructed from the documented project and code. Results and verification limits are described below. [SVG](docs/flowcharts/motor.svg)

## Project configuration and team

The project covers measurement and calibration, sinusoidal response experiments, model identification and controller design. Sangheon Park first obtained working results for the measurement setup, sensor/input calibration and response-data collection. 김찬중 first obtained working results for model identification, model comparisons and controller design with target-angle response analysis.

Both members also worked through the complete process from setup to controller study. This division records who first brought each stage to a working result, rather than exclusive ownership of those stages. The files in this repository focus on the recorded data and identification analysis; the wider project also included controller-design experiments.

## From measurement to controller study

The work began with the DAQ setup and sensor/input calibration. Sinusoidal commands were then applied at several frequencies, with each run saved for analysis. MATLAB fits the recorded response at each frequency to estimate its amplitude and phase, combines those measurements into a frequency response, and identifies candidate models. Simulink comparisons show how those models reproduce the measured response. The wider project continued into controller design and target-angle response comparisons.

The repository currently preserves the measurement data and identification replay. The later controller study belongs to the project history, but its complete experiment setup is not supplied by this package.

## What was measured

The question was how strongly, and how quickly, the motor responded to a changing command. We applied sinusoidal inputs at a sequence of frequencies and recorded the output. A slow input and a faster input do not produce the same output amplitude or delay; that relationship is the basis of the frequency-response model.

The included dataset contains twelve runs from 0.1 to 1.2 Hz. Each file has 4,000 rows with three columns: time, command voltage and the stored gyro-derived response. The voltage column is the command before the acquisition program's linearisation step, so it should not be read as a direct recording of the final DAQ output. The original acquisition and calibration setup is not reproduced by these files.

## Recorded response

![Archived motor command voltage and gyro response](assets/recorded-response.png)

This plot contains 4,000 samples from a recorded 0.30 Hz experiment. The upper panel shows command voltage. The lower panel uses the response units stored in the original data because the sensor calibration has not been independently rechecked.

## Analysis

[chan.m](Gimbal_board/chan.m) loads the recorded runs and fits a sinusoid to each output response. The fitted amplitude and phase describe the motor's response at that test frequency. The script divides the output amplitude by the prescribed input amplitude to obtain gain, then combines gain and phase into a complex frequency response.

It uses that response to identify two candidate transfer functions. A transfer function describes the relationship between input and output in a compact mathematical model. Here, the second candidate has one zero and two poles; its extra order comes from the fitted motor response, not from appending an integrator to convert velocity to position. The script compares the models' frequency responses and uses [Plant.slx](Simulink/Plant.slx) to compare simulated output with the recorded response.

The original `chan.m` script and its two `Plant.slx` simulations ran in MATLAB R2024b on 28 September 2026. The script produced these approximate models:

```text
Gp1(s) = 7656 / (s + 13.12)
Gp2(s) = (1.137e4 s + 5.346e4) / (s^2 + 27.32 s + 84.84)
```

These are reproduced script outputs. The fitting routine reported possible local minima, so they should not be treated as independently validated estimates. Successful replay also does not establish closed-loop hardware performance. No motor was operated during the replay.

## Replaying the analysis

The repository now includes [chan.m](Gimbal_board/chan.m), [Plant.slx](Simulink/Plant.slx) and the twelve recorded runs from 0.1 to 1.2 Hz. This package was replayed successfully in MATLAB R2024b on Windows on 28 September 2026. From the repository root, use the following commands in MATLAB:

```matlab
cd Gimbal_board
chan
```

The script clears the workspace and opens its analysis figures. Keep the neighbouring `Simulink` folder and the measurement filenames intact because the script expects that layout. The script uses Simulink, Control System Toolbox, Signal Processing Toolbox, Optimization Toolbox and Curve Fitting Toolbox; its original Windows paths are retained.

To regenerate the response plot, install NumPy and Matplotlib and run `python plot_recorded_response.py` from the repository root. It writes `portfolio/recorded-response.png` and checks the recorded samples for finite values and increasing time. The acquisition software and hardware setup are not included.


For a quick review, begin with the recorded-response plot, then read the fitting section in `chan.m`. Reproducing the script demonstrates that the preserved data and analysis run together. It does not establish a best-fit model for another motor, independently validate the sensor scale, or repeat the original closed-loop target-angle experiment.

