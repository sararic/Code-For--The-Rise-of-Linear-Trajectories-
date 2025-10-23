# Code for “The Rise of Linear Trajectories”

This repository contains the code and data used to generate the plots in
our paper
[The Rise of Linear Trajectories](https://arxiv.org/abs/2510.07991).
This is broken down in two parts:

## Forward Limit Bounds

These bounds make up the data for Figs. 1–3.

- The data for the bound is prepared in
  [`forward_bounds.nb`](forward_bounds.nb). Note that we use
  [crossing symmetric dispersion relations](https://doi.org/10.1103/PhysRevLett.126.181601)
  to simplify the calculation (notably for null constraints). One can
  verify that the sum rules and null constraints thus obtained are
  exactly the same as the ones presented in the paper.
- The computation is done server-side using
  [`sdpb`](https://github.com/davidsd/sdpb) and `slurm`. The server-side
  code is contained in the [`sdpbRun`](sdpbRun) directory.
- The directories [`spectra_fig_1`](spectra_fig_1) and
  [`spectra_fig_3`](spectra_fig_3) contain the raw values for the
  spectra extracted at
  each point. These values can be read using the dedicated functions in
  [`forward_bounds.nb`](forward_bounds.nb).

## Non-Forward Bounds

These bounds make up the data for Figs. 4–5.

- The data for the bound is prepared with several codes. We prepare the
  json file in [`run.sh`](run.sh), the values of the masses can be
  changed in [`generate.m`](generate.m). The sdpb run is done in
  [`run-l-g.sh`](run-l-g.sh). Note that we use the forward limit
  dispersion relation here as we describe in our paper.

## Other Files

- The file [`Plots.nb`](Plots.nb) contains the code that generates all the plots, in a comprehensible format. The exact values plotted can be found there as well.
