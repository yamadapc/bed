module bed;

public import reporters;
public import runnable;
public import spec;
public import suite;

static Suite currentSuite;

void describe(R = SpecReporter)(string title, Block block)
{
  if(currentSuite is null)
  {
    currentSuite = new Suite(title);
  }
  else
  {
    auto suite = new Suite(title, currentSuite);
    currentSuite.children ~= suite;
    currentSuite = suite;
  }

  block();

  if(!currentSuite.isRoot)
  {
    currentSuite = cast(Suite) currentSuite.parent;
  }
  else
  {
    auto rep = new R(currentSuite);
    currentSuite.run();
    assert(!currentSuite.failed, "One or more tests failed");
    currentSuite = null;
  }
}

void it(string title, Block block)
{
  auto spec = new Spec(title, currentSuite, block);
  currentSuite.specs ~= spec;
  spec.connect(&currentSuite.propagateFailure);
}
