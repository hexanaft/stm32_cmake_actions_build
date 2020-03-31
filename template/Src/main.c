#include "main.h"

void SystemInit (void)
{

}
int main(void)
{

  /* Infinite loop */
  while (1)
  {
  }
}

int _exit (int status)
{
    (void)status;
    while (1) {}        /* Make sure we hang here */
}
