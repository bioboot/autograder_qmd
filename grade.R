library(gradeR)

#- Writes output to either `/autograder/results/results.json` 
#-    or cwd `./results.json` (with `which_results="testing"`)  

calcGradesForGradescope(submission_file = "hw1.R",    # each student's submission must be named this!
                        test_file = "tests.r",        # the testthat tests 
                        which_results = "gradescope") # or set to "testing" if not on gradescope 
