module bed.interfaces.bdd;

import core.thread;

import bed.core;
import bed.tests;

void describe(string title, Block block)
{
  addTestSuite(title, block);
}

void it(B)(string title, B block)
{
  addTestCase(title, block);
}
