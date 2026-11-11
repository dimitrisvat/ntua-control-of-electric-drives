# Induction Motor Modelling and V/f Control

A comparison of dynamic and quasi-steady-state induction-motor models, followed by load-dependent startup studies and scalar V/f control.

## Documentation

- [English technical overview](overview_english.md)
- [English overview (PDF)](overview_english.pdf)
- [Full Greek report](report_greek.pdf)

## Models

- [`ex2.slx`](models/ex2.slx)
- [`ex4.slx`](models/ex4.slx)
- [`ex6_1.slx`](models/ex6_1.slx)
- [`ex6_2.slx`](models/ex6_2.slx)
- [`ex7.slx`](models/ex7.slx)

## Running the project

Use MATLAB/Simulink R2025b or a compatible newer release; this release is recorded in the model metadata. Set the current folder to `models/`, then open `sim2.m`. Run the parameter initialization portion before the first plotting operation that reads `out`, open the desired `.slx` model, and simulate it. Run only the matching plotting section after its required logged signals exist.

The original scripts combine initialization, multiple experiments and post-processing. Running an entire script from a clean workspace may fail because plotting sections expect earlier simulation output. Plotting helpers and the original `Figures/` path are retained. Some comparison sections require saved results from multiple runs.

See the [repository run notes](../RUNNING.md) for dependencies and verification scope.
