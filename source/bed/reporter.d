/**
 * Reporter interface and thread starter.
 */

module bed.reporter;

import std.concurrency : OwnerTerminated, receive, Tid;
import std.stdio;

import colorize;

import bed.runner;
import bed.tests;

shared interface Reporter
{
  void onNewRootTestSuite(string);
  void onNewTestSuite(string, string);
  void onNewSerialTestCase(SerialTestCase);
  void onNewParallelTestCase(ParallelTestCase);
  void onTestCaseFailure(TestCaseFailure);
  void onTestCaseSuccess(TestCaseResult);

  final void start()
  {
    writeln("Starting reporter");
    auto running = true;
    while(running)
    {
      receive(
        &onNewTestSuite,
        &onNewRootTestSuite,
        &onNewSerialTestCase,
        &onNewParallelTestCase,
        &onTestCaseFailure,
        &onTestCaseSuccess,
        (OwnerTerminated _) { running = false; }
      );
    }
  }
}

shared class SpecReporter : Reporter
{
  void onNewRootTestSuite(string ts)
  {
    cwritefln("New root test suite: '%s'".color(fg.yellow), ts);
  }

  void onNewTestSuite(string ts, string parentTs)
  {
    cwritefln(
      "New test suite: '%s' (came from %s)".color(fg.yellow),
      ts,
      parentTs
    );
  }

  void onNewSerialTestCase(SerialTestCase tc)
  {
    cwritefln("New serial test case: '%s'".color(fg.yellow), tc.title);
  }

  void onNewParallelTestCase(ParallelTestCase tc)
  {
    cwritefln("New parallel test case '%s'".color(fg.magenta), tc.title);
  }

  void onTestCaseFailure(TestCaseFailure tc)
  {
    cwritefln("New test case failure: '%s'".color(fg.red), tc.title);
    cwritefln("   ERROR: '%s'".color(fg.red), tc.msg);
    cwritefln("   INFO:\n%s".color(fg.red), tc.info);
  }

  void onTestCaseSuccess(TestCaseResult tc)
  {
    cwritefln("New test case success: '%s'".color(fg.green), tc.title);
  }
}
