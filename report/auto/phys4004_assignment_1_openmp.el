(TeX-add-style-hook
 "phys4004_assignment_1_openmp"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("article" "draft")))
   (TeX-run-style-hooks
    "latex2e"
    "article"
    "art10"
    "base"
    "color"
    "listings")
   (LaTeX-add-labels
    "sec:Overview"
    "sec:serial-code"
    "sec:original-serial-code"
    "sec:improved-serial-code"
    "sec:profiling-comparison"
    "sec:loop-parallel-code"
    "sec:results"
    "sec:unif-behav-verif"
    "sec:scaling-behaviour"
    "sec:thre-indep-verif"))
 :latex)

