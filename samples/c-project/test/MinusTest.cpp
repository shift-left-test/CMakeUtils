#include <gtest/gtest.h>

extern "C" {
  #include "minus.h"
}

TEST(MinusTest, testShouldReturnExpectedValue) {
  ASSERT_EQ(-1, minus(1, 2));
}
