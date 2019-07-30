#include <stdio.h>
#include "plus.h"
#include "minus.h"

int main(int argc, char *argv[]) {
  printf("(1 + 2) + (1 - 2) = %d\n", plus(1, 2) + minus(1, 2));
  return 0;
}
