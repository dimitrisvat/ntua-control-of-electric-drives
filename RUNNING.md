# Running the Electric Drives projects

## Requirements

The saved Simulink model metadata identifies MATLAB/Simulink R2025b. Use that release or a compatible newer one. Older installations may require an explicit export from a newer release. Additional block dependencies should be resolved as reported by Simulink when loading a model.

## Workflow

1. Open one exercise's `models/` directory as the MATLAB current folder.
2. Open its `sim1.m`, `sim2.m`, `sim3.m` or `sim4.m` script.
3. Execute the parameter initialization code needed for the chosen experiment. Stop before plotting code that reads `out` or other results that do not yet exist.
4. Open the desired `.slx` model and inspect its references, load schedule and simulation settings against the report.
5. Run the simulation, then execute only the corresponding post-processing section.
6. For comparisons, retain the outputs from the required runs as expected by the plotting section before generating the combined figure.

The scripts are original interactive coursework scripts, not unattended batch entry points. Running a full script can clear earlier results and then fail at a plotting section expecting `out`. `format_and_export.m` and the `Figures/` directories retain the original export workflow. Model filenames are reused between exercises, so work in one exercise at a time rather than adding all folders recursively to the MATLAB path.

## Reports and saved results

Exercises 1-3 include reports whose filenames explicitly identified them as corrected; exercise 4 includes the available final report. English technical overviews summarize the methods and reported results. They are not full translations and do not replace the complete derivations and figure sequences in the Greek originals.

## Verification scope

File integrity, SLX archive/XML structure, saved release metadata, documentation links and PDF rendering are checked during preparation. Numerical simulation results are those recorded in the coursework; all experiments have not been re-run. Models and scripts are preserved without numerical changes. Simulation caches, autosaves, backup versions, textbooks and other students' work are excluded.

## Attribution

Reports credit Dimitris Vatalas. The projects were completed within NTUA coursework and may build on course-provided machine models or equations. No blanket license is applied to course-provided material.
