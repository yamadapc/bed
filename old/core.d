module bed.core;

import std.algorithm;
import std.array;
import std.concurrency;
import std.parallelism;
import std.typecons;
import std.signals;

import core.thread;

public import bed.tests;
public import bed.interfaces.bdd;
public import bed.reporters;

class Bed
{
  // Bed instance singleton.
  // There should only ever be one instance of bed around.
  static Bed get()
  {
    if(_instance is null) return _instance = new Bed();
    else return _instance;
  }

  static void useReporter(R : Reporter)(R reporter)
  {
    _reporters = [reporter];
  }

  static void addReporter(R : Reporter)(R reporter)
  {
    _reporters ~= reporter;
  }

  void addTestSuite(TestSuite ts)
  {
  }

  static void listen()
  {
    auto running = true;
    while(running)
    {
      receive(
        &onTestCaseEnd,
        (OwnerTerminated _) => running = false
      );
    }
  }

  void start()
  {
    auto tid = spawn(&listen);
    // Attach reporters to the root test suite
    foreach(reporter; _reporters) reporter.listen(rootTs);
    // Run the test suite - this includes loading nested suites
    // Make each reporter print the test suite summary
    foreach(reporter; _reporters) reporter.summary;
  }

package:

  void onTestCaseEnd(string title, Throwable err)
  {
    foreach(reporter; _reporters) reporter.onTestCaseEnd(title, err);
  }

private:
  static Bed _instance;
  static Reporter[] _reporters = [new SpecReporter];
  TestSuite rootTs;
  TestSuite currentTs;

  this() {}
}

unittest
{
  import std.stdio;

  auto bed = Bed.get();
  bed.addTestSuite(new TestSuite("Something", {}));
  bed.addTestCase(TestCase("nested 1", {
    Thread.sleep(1000.msecs);
  }));
  bed.addTestCase(TestCase("nested 2", {
    Thread.sleep(2000.msecs);
  }));
  bed.start();
}
