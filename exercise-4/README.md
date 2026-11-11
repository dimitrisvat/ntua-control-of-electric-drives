# Improved Vector Control and Field Weakening

An extension of indirect field-oriented control that tests parameter sensitivity, adds a voltage-error correction to the current model and investigates high-speed field weakening.

## Documentation

- [English technical overview](overview_english.md)
- [English overview (PDF)](overview_english.pdf)
- [Full Greek report](report_greek.pdf)

## Models

- [`ex1.slx`](models/ex1.slx)
- [`ex2.slx`](models/ex2.slx)
- [`ex3.slx`](models/ex3.slx)
- [`ex3_2.slx`](models/ex3_2.slx)
- [`ex4.slx`](models/ex4.slx)

## Running the project

Use MATLAB/Simulink R2025b or a compatible newer release; this release is recorded in the model metadata. Set the current folder to `models/`, then open `sim4.m`. Run the parameter initialization portion before the first plotting operation that reads `out`, open the desired `.slx` model, and simulate it. Run only the matching plotting section after its required logged signals exist.

The original scripts combine initialization, multiple experiments and post-processing. Running an entire script from a clean workspace may fail because plotting sections expect earlier simulation output. Plotting helpers and the original `Figures/` path are retained. Some comparison sections require saved results from multiple runs.

See the [repository run notes](../RUNNING.md) for dependencies and verification scope.
