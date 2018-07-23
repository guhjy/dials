library(testthat)
library(dials)

context("qualitative parameter values")

test_that('transforms with unknowns', {
  expect_error(
    value_transform(regularization, unknown())
  )
  expect_error(
    value_transform(regularization, c(unknown(), 1, unknown()))
  )  
  expect_error(
    value_inverse(regularization, unknown())
  )
  expect_error(
    value_inverse(regularization, c(unknown(), 1, unknown()))
  )  
})


test_that('transforms', {
  expect_equal(
    value_transform(regularization, 1:3), log10(1:3)
  )
  expect_equal(
    value_transform(regularization, -1:3), c(NaN, -Inf, log10(1:3))
  )
  expect_equal(
    value_transform(mtry, 1:3), 1:3
  )  
})


test_that('inverses', {
  expect_equal(
    value_inverse(regularization, 1:3), 10^(1:3)
  )
  expect_equal(
    value_inverse(regularization,  c(NA, 1:3)), c(NA, 10^(1:3))
  )
  expect_equal(
    value_inverse(mtry, 1:3), 1:3
  )  
})


test_param_1 <-
  new_quant_param(
    type = "integer",
    range = c(1L, 10L),
    inclusive = c(TRUE, TRUE),
    trans = NULL,
    default = 3
  )
test_param_2 <-
  new_quant_param(
    type = "integer",
    range = c(2.1, 5.3),
    inclusive = c(TRUE, TRUE),
    trans = sqrt_trans(),
    default = sqrt(2)
  )
test_param_3 <-
  new_quant_param(
    type = "double",
    range = 0:1,
    inclusive = c(TRUE, TRUE),
    trans = NULL,
    default = .40
  )
test_param_4 <-
  new_quant_param(
    type = "double",
    range = 0:1,
    inclusive = c(TRUE, TRUE),
    trans = sqrt_trans(),
    default = sqrt(.6)
  )


test_that('sequences - doubles', {
  expect_equal(
    value_seq(mixture, 5), seq(0, 1, length = 5)
  )  
  expect_equal(
    value_seq(mixture, 1), 0
  )
  expect_equal(
    value_seq(test_param_3, 1), .40
  ) 
  expect_equal(
    value_seq(test_param_4, 1), .60
  )    
  expect_equal(
    value_seq(regularization, 5, FALSE), seq(-10, 0, length = 5)
  )  
  expect_equal(
    value_seq(regularization, 1, FALSE), -10
  )
  expect_equal(
    value_seq(test_param_4, 1, FALSE), sqrt(.6)
  )    
})


test_that('sequences - integers', {
  expect_equal(
    value_seq(tree_depth, 5), c(2, 5, 8, 11, 15)
  )  
  expect_equal(
    value_seq(tree_depth, 1), 2L
  ) 
  expect_equal(
    value_seq(test_param_1, 1), 3L
  )  
  expect_equal(
    value_seq(test_param_2, 1), 2L
  )   
  expect_equal(
    value_seq(tree_depth, 14), 2L:15L
  )  
  expect_equal(
    value_seq(tree_depth, 5, FALSE), seq(2, 15, length = 5)
  )  
  expect_equal(
    value_seq(tree_depth, 1, FALSE), 2L
  ) 
  expect_equal(
    value_seq(test_param_1, 1, FALSE), 3L
  )  
  expect_equal(
    value_seq(test_param_2, 1, FALSE), sqrt(2)
  )   
  expect_equal(
    value_seq(tree_depth, 14, FALSE), 2L:15L
  )    
})


test_that('sampling - doubles', {
  set.seed(2489)
  mix_test <- value_sample(mixture, 5000)
  expect_true(min(mix_test) > 0)
  expect_true(max(mix_test) < 1) 
  
  set.seed(2489)
  L2_orig <- value_sample(regularization, 5000)
  expect_true(min(L2_orig) > 10^regularization$range$lower)
  expect_true(max(L2_orig) < 10^regularization$range$upper) 
  
  set.seed(2489)
  L2_tran <- value_sample(regularization, 5000, FALSE)
  expect_true(min(L2_tran) > regularization$range$lower)
  expect_true(max(L2_tran) < regularization$range$upper)   
})

test_that('sampling - integers', {
  set.seed(2489)
  depth_test <- value_sample(tree_depth, 500)
  expect_true(min(depth_test) >= tree_depth$range$lower)
  expect_true(max(depth_test) <= tree_depth$range$upper) 
  expect_true(is.integer(depth_test))
  
  set.seed(2489)
  p2_orig <- value_sample(test_param_2, 500)
  expect_true(min(p2_orig) >= floor(2^test_param_2$range$lower))
  expect_true(max(p2_orig) <= floor(2^test_param_2$range$upper))
  expect_true(is.integer(p2_orig))
  
  set.seed(2489)
  p2_tran <- value_sample(test_param_2, 500, FALSE)
  expect_true(min(p2_tran) > test_param_2$range$lower)
  expect_true(max(p2_tran) < test_param_2$range$upper) 
  expect_true(!is.integer(p2_tran))
  
})

context("qualitative parameter values")

test_param_5 <-
  new_qual_param(
    type = "character",
    values = letters[1:10],
    default = "c"
  )
test_param_6 <-
  new_qual_param(
    type = "logical",
    values = TRUE
  )

test_that('sequences - character', {
  expect_equal(
    value_seq(surv_dist, 5), surv_dist$values[1:5]
  )  
  expect_equal(
    value_seq(surv_dist, 1), surv_dist$values[1]
  )   
  expect_equal(
    value_seq(surv_dist, Inf), surv_dist$values
  )     
  expect_equal(
    value_seq(test_param_5, 1), "c"
  )    
})

test_that('sequences - logical', {
  expect_equal(
    value_seq(prune, 1), TRUE
  )  
  expect_equal(
    value_seq(prune, 2), c(TRUE, FALSE)
  )   
  expect_equal(
    value_seq(prune, 21), c(TRUE, FALSE)
  )    
  expect_equal(
    value_seq(test_param_6, Inf), TRUE
  )     
})


test_that('sampling - character and logical', {
  set.seed(9950)
  expect_equal(
    sort(unique(value_sample(surv_dist, 500))), sort(surv_dist$values)
  )  
  set.seed(9950)
  expect_equal(
    sort(unique(value_sample(prune, 500))), sort(prune$values)
  )   
})



