(TeX-add-style-hook
 "phys4004_assignment_1_openmp"
 (lambda ()
   (add-to-list 'LaTeX-verbatim-environments-local "lstlisting")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "lstinline")
   (TeX-run-style-hooks
    "latex2e"
    "article"
    "art10"
    "base"
    "color"
    "listings")
   (LaTeX-add-labels
    "sec:Overview"
    "sec:code-synopsis"
    "sec:common-code"
    "sec:serial-code"
    "sec:original-serial-code"
    "sec:improved-serial-code"
    "sec:profiling-comparison"
    "sec:parallel-loop-code"
    "sec:bash-scripts"
    "sec:gol-job"
    "sec:gol-job-set"
    "sec:gol-data"
    "sec:results"
    "sec:unif-behav-verif"
    "sec:scaling-behaviour"
    "fig:scaling"
    "sec:thre-indep-verif"
    "sec:thread-scaling-behaviour"
    "fig:parallel_scaling"
    "sec:appendix"
    "sec:common_fort"
    "sec:01_gol_cpu_serial_fort"
    "sec:02_gol_cpu_serial_fort"
    "sec:02_gol_cpu_openmp_loop_fort"
    "sec:gol-job-submission"
    "sec:gol-job-set-submission"
    "sec:gol-data-extract")
   (LaTeX-add-listings-lstdefinestyles
    "ff"))
 :latex)

