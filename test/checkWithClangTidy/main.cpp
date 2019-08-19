#include <iostream>
#include "Number.hpp"

int main() {
  Number number(10);
  std::cout << number.plus(1) + number.minus(1) << std::endl;
  return 0;
}
