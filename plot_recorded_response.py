"""Plot one archived motor experiment; no acquisition or motor commands."""

from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np


def main():
    root = Path(__file__).resolve().parent
    source = root / "Gimbal_board/gimbal_Gyro_modeling/chan_modeling_0.3000Hz_data.out"
    data = np.loadtxt(source)
    if data.ndim != 2 or data.shape[1] != 3 or not np.isfinite(data).all():
        raise ValueError("Expected finite time, command-voltage and response columns")
    if not np.all(np.diff(data[:, 0]) > 0):
        raise ValueError("Recorded time must be strictly increasing")
    with plt.rc_context({"font.size": 10}):
        fig, axes = plt.subplots(2, 1, figsize=(10, 6), sharex=True, layout="constrained")
        axes[0].plot(data[:, 0], data[:, 1], color="#255f85", linewidth=1.4)
        axes[0].set_ylabel("Command voltage [V]")
        axes[1].plot(data[:, 0], data[:, 2], color="#ae4f31", linewidth=0.8)
        axes[1].set_ylabel("Gyro-derived response\n[stored angular-velocity units]")
        axes[1].set_xlabel("Time [s]")
        for ax in axes:
            ax.grid(alpha=0.25)
        fig.suptitle("Archived motor experiment | 0.30 Hz sinusoidal input\nRecorded data replay; sensor calibration not revalidated")
        output = root / "portfolio/recorded-response.png"
        output.parent.mkdir(exist_ok=True)
        fig.savefig(output, dpi=160)
        plt.close(fig)
    print(f"Validated {len(data)} finite, time-ordered samples; wrote {output}")


if __name__ == "__main__":
    main()
