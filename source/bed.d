module bed;

public import reporters;
public import runnable;
public import spec;
public import suite;

static Suite[] suites;
static Suite currentSuite;

void describe(string title, Block block)
{
  if(currentSuite is null)
  {
    currentSuite = new Suite(title);
  }
  else
  {
    auto suite = new Suite(title, currentSuite);
    currentSuite.suites ~= suite;
    currentSuite = suite;
  }

  block();

  if(!currentSuite.isRoot)
  {
    currentSuite = cast(Suite) currentSuite.parent;
  }
  else
  {
    suites ~= currentSuite;
    currentSuite = null;
  }
}

void it(string title, Block block)
{
  auto spec = new Spec(title, currentSuite, block);
  currentSuite.specs ~= spec;
  spec.connect(&currentSuite.propagateFailure);
}

void before(Block block)
{ currentSuite.befores ~= block; }

void beforeEach(Block block)
{ currentSuite.beforeEachs ~= block; }

void after(Block block)
{ currentSuite.afters = block ~ currentSuite.afters; }

void afterEach(Block block)
{ currentSuite.afterEachs = block ~ currentSuite.afterEachs; }

static ~this()
{
  import std.c.process : exit;
  import colorize : fg;
  import colorize.colorize : colorize;
  auto rootSuite = new Suite("\n -- bed --\n".colorize(fg.yellow));

  foreach(suite; suites)
  {
    suite.parent = rootSuite;
    rootSuite.suites ~= suite;
  }

  auto rep = new SpecReporter(rootSuite);
  rootSuite.run();
  if(rootSuite.failed) exit(1);
}
