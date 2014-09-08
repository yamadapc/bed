import testsuite;
import runner;

static string reporter = "spec";
static Reporter currentReporter;

static auto newReporter(TestSuite testsuite)
{
  switch(reporter)
  {
    case "spec": return new SpecReporter(testsuite);
    default: throw new Exception("Unknown reporter");
  }
}

static auto getReporter()
{
  return currentReporter;
}
