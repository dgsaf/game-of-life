(TeX-add-style-hook
 "phys4004_assignment_1_openmp"
 (lambda ()
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
    "sec:bash-scripts"
    "sec:serial-code"
    "sec:original-serial-code"
    "sec:improved-serial-code"
    "sec:profiling-comparison"
    "sec:parallel-loop-code"
    "sec:results"
    "sec:unif-behav-verif"
    "sec:scaling-behaviour"
    "sec:thre-indep-verif"
    "sec:appendix"))
 :latex)

