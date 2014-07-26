module bed;

public import reporters;
public import runnable;
public import spec;
public import suite;

void describe(R = SpecReporter)(string title, SuiteBlock block)
{
  auto suite = new Suite(title);
  block(suite);

  auto rep = new R(suite);
  suite.run();

  assert(!suite.failed, "One or more tests failed");
}

unittest
{
  import test.spec;
  import test.runnable;
  import test.suite;
}
