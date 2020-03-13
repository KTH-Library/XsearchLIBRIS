test_that("crawl works (paging search results w > 200 hits)", {
  t1 <- xsearch_crawl(query = "corona", database = "swepub")$content
  expect_gt(nrow(t1), 200)
})
