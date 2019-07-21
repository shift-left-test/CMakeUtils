#include <gtest/gtest.h>

class FirstTest : public ::testing::Test {
};

TEST_F(FirstTest, test1) {
  ASSERT_EQ(1, 1);
}
