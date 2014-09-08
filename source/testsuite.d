import std.algorithm;
import std.array;
import std.concurrency;
import std.parallelism;
import std.typecons;
import std.signals;

import settings;

alias Block = void function();
alias Result = Throwable;

class TestSuite
{
  string title;
  Block block;
  bool isRoot = false;
  TestCase testcases[string];
  TestSuite testsuites[string];

  this(string _title, Block _block)
  {
    title = _title;
    block = _block;
  }

  void addTestSuite(TestSuite testsuite)
  {
    auto title = testsuite.title;
    if((title in testsuites) is null) testsuites[title] = testsuite;
    else throw new Exception("Cannot register duplicate test suites.");
  }

  void addTestCase(TestCase testcase)
  {
    auto title = testcase.title;
    if((title in testcases) is null) testcases[title] = testcase;
    else throw new Exception("Cannot register duplicate test cases.");
  }

  void run()
  {
    auto testcases = testcases.values;
    auto results = taskPool.amap!runTestCase(testcases);

    foreach(i, result; results)
    {
      testcases[i].err = result;
    }
  }
}

struct TestCase
{
  string title;
  Block block;
  Throwable err;

  @property bool failed()
  {
    return err !is null;
  }
}

Result runTestCase(TestCase testcase)
{
  Throwable e = null;
  try testcase.block();
  catch(Throwable e_) e = e_;

  getReporter().onTestCaseEnd(testcase);

  return e;
}
