#include <gtest/gtest.h>

class SecondTest : public ::testing::Test {
};

TEST_F(SecondTest, test1) {
  ASSERT_EQ(2, 2);
}
