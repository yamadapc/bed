module bed.interfaces.bdd;

import core.thread;

import bed.core;
import bed.tests;

void describe(string title, Block block)
{
  Bed.get().addTestSuite(TestSuite(title));
  block();
}

void it(B)(string title, B block)
{
  Bed.get().addTestCase(TestCase(title, block));
}
