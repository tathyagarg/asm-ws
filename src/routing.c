#include <stdio.h>

int main() {
  volatile unsigned int *const UART0DR = (unsigned int *)0x402840;
  printf("%u\n", *UART0DR);
}
