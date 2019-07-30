#include <gtest/gtest.h>
#include "module.hpp"

TEST(module_test, test) {
  EXPECT_EQ(3, plus(1, 2));
}
