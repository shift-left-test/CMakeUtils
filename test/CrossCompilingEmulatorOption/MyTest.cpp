#include <gtest/gtest.h>

class MyTest : public ::testing::Test {
};

TEST_F(MyTest, test1) {
  ASSERT_EQ(1, 1);
}
