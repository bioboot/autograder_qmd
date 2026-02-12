library(testthat)

# each call to test_that() produces one test
# each test represents one point value
# you can have multiple tests for each question


test_that("Q1 (visible)", {
  
  expect_equal( sum(myVector), 6) 

})

test_that("Q2 (invisible)", {

  expect_true(is.character(myString))
  expect_true(nchar(myString) > 2)

})

test_that("Q3 (visible)", {
  
  expect_equal( length(x), 1) 
  expect_equal(x, 100, tolerance=1e-3)


})