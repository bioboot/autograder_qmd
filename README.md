# Setting up autograding of R quarto docs on Gradescope

## Background	
Gradescope provides a docker-based autograding system
https://gradescope-autograders.readthedocs.io/en/latest/

Once setup (see below) students can submit an R script (.R), quarto doc (.qmd), or R Markdown (.Rmd) file to gradescope and receive near immediate feedback based on the autograding test code we as instructors setup. 


## Overview:
1. Instructor creates a coding assignment on gradescope.com, sets submission dates and pts etc.

2. Instructor creates a **zip file** containing two required shell scripts (with the specific names  `setup.sh` and `run\_autograder` ) and at least two R scripts that do the grading and forming of results for gradescope (see below).

3. Student submits QMD or R script

4. Gradescope runs the student's code in a Docker container, executes the tests, and returns grades/feedback.


## Required Components of the .zip archive file
As mentioned in pt 2 above you must create a **zip file** for Gradescope that contains at least 4 files:

- ​**setup.sh**​: A bash shell script that runs once to install R and any required R packages (e.g., ​*gradeR*​,  *testthat, tidyverse, bio3d,*  etc...), 

- ​**run_autograder**​: An executable bash script that runs every time a student submits. It should call your your *grade.R*  code (see below) and produce the output in the correct directory for gradescope,

- ​**grade.R**​: An R script who’s only job is to run your *testing script*  (called ​*tests.R,*​ see below) and write output to a required *results.json* file in gradescope JSON format. 
	- This script typically runs the function `gradeR::calcGradesForGradescope()`  to run your main *tests.R* script  that does the actual grading tests on a single student submission and generate a JSON file with results for gradescope.

- ​**tests.R**​: An R script that evaluates the student’s submission by checking student created objects against expected answers (i.e. does the grading work)
	- This will typically use functions like `testthat::expect\_true()` to test if certain variables that students make in their submission script are what we ***expect*** them to be (i.e. they have the right answer) see details below.

- ​Optional **Data files**​: You also need to add any necessary **data files** for the assignment to the zip archive or else the student submission code will not run.



> ​**Side note**​: The `calcGradesForGradescope()` function from the ​**gradeR**​ package is useful as it can produce the expected JSON output that GradeScope wants.  
> 
> The ​**testthat**​ package is also super useful and we will use different `expect_()` functions in our test script ​**tests.R**​ to test certain key variables that students make in their submission script (see details below).


### More details on each of these required files
 We upload to gradescope as a singe **.zip** file that contains all four files:

#### 1.    setup.sh
Basically a bash script that Gradescope’s Linux servers run once to get all software we need for the assignment setup (like R itself, the gradeR and testthat packages and any packages the students uses in the assignment). For example:

```
#!/usr/bin/env bash

##- Install R on ubuntu
apt-get install -y libxml2-dev libcurl4-openssl-dev libssl-dev
apt-get install -y r-base

##- Install the needed R packages
Rscript -e "install.packages('gradeR')"
Rscript -e "install.packages('stringr')"
```


#### 2.   run\_autograder
Another Bash script that Gradescope’s Linux servers run every time a single student submission needs to be graded.

N.B. this file must have this name, ( `run_autograder` ) because Gradescope expects this.

It copies a single student submission into the directory that the Gradescope server expects (namely ), and then it runs the **test.R** grading script that does the main work of grading.


```
#!/usr/bin/env bash

##- 1. Copy student submission file to source dir:
cp /autograder/submission/assignment1.R /autograder/source/assignment1.R

##- 2. Change to this dir
cd /autograder/source

##- 3. Optional update of tests.R for debugging
##-    Uncomment to fetch latest tests.R from GitHub before running
# wget -q https://raw.githubusercontent.com/bioboot/autograder_qmd/refs/heads/main/tests.R

##- Run the grading script in the \`source/\` dir:
LC_ALL= Rscript grade.r
```
  


#### 3.   grade.R
The first “controller” R script that runs the main testing script on each student submission. 

This file can actually be named anything you want as long as you use that name in the `run\_autograder` shell script. 

Thanks to the **gradeR** package this one is pretty simple - it just calls `gradeR::calcGradesForGradescope()` with the name of the student submission file and the name of the main testing R script,  e.g.:

```
library(gradeR)

#- Writes output to `/autograder/results/results.json` 
#-    or `./results.json` (which_results="testing")  
calcGradesForGradescope(submission_file = "assignment1.R", 
						test_file = "tests.r", 
						which_results = "gradescope") # or set to "testing" 

```
 

Note that the output of this function `results.json` is formatted the way that Gradescope expects (basically a JSON file with specific entries). This is why we use it ;-)


#### 4.    tests.R 
This is your main testing R script with all the `testthat` function tests that check student produced objects (i.e. their answers) with what you expect them to be.

Most of the time you will be testing if certain variables that students make in their submission script are what you ***expect*** them to be (i.e. they have the right answer ;-)

We will use the **testthat** package and it’s set of `expect\_\*()` functions to this. 

The most common ones include `expect\_equal()`  `expect\_identical()`  `expect\_match()`  `expect\_true()`   `expect\_false()` expect\_length() expect\_all\_equal() expect\_all\_true()   etc....    see full list: https://testthat.r-lib.org/reference/index.html

```
library(testthat)

# Each call to the test_that() function produces one test yielding 1 pt.
# You can have multiple tests for each question

test_that(“Q1 (visible)", {
  expect_equal( sum(myVector), 6) 
})

```



#### 5.   Other files
Remember to include any extra data files needed for a given homework (e.g. CSV files that the students are using). If you don’t included these then running the student submission code will fail and there will be nothing to test...





# A note on debuging
Note that Gradescope will annoyingly need to build a new Docker image every time you upload a new autograder zip. This making debugging very time consuming and annoying. 

I recommend adding something like ​`wget`​ ​`https://[your`​ ​`server/tests.R`​  to `run\_autograder` . This enables you to change the grading tests script without rebuilding the Docker image every time.

For example, in your `run\_autograder`  script, add something like:

```
#!/usr/bin/env bash

##- Copy student submission file to source dir:
cp /autograder/submission/assignment1.R /autograder/source/assignment1.R

##- Change to this dir
cd /autograder/source

##- Fetch latest tests.R from GitHub before running
wget -q https://raw.githubusercontent.com/bioboot/autograder_qmd/refs/heads/main/tests.R 

##- Then run your grading as normal
LC_ALL=Rscript run_grader.R
```


