#include <gtest/gtest.h>

extern "C" {
  #include "plus.h"
}

TEST(PlusTest, testShouldReturnExpectedValue) {
  ASSERT_EQ(3, plus(1, 2));
}
