#include "Number.hpp"

Number::Number(int base) : base(base) {
}

int Number::plus(int value) {
  return base + value;
}

int Number::minus(int value) {
  return base - value;
}
