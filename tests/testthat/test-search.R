test_that("search for film noir returns more than five hits", {
  t1 <- xsearch(query = "WAMK:\"film noir\"")$content
  expect_gt(nrow(t1), 5)
})

test_that("search for film noir returns more than five hits", {
  t1 <- xsearch(query = "PERS:(thisisanunknownpersonnosearchhitsexpected) SPR:swe")$content
  expect_equal(nrow(t1), 0)
})

