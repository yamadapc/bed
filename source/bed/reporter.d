/**
 * Reporter interface and thread starter.
 */

module bed.reporter;

import std.algorithm;
import std.array;
import std.concurrency : OwnerTerminated, receive, Tid;
import std.datetime;
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
  private void log(T...)(string fmt, T vs)
  {
    auto now = Clock.currTime.toSimpleString.splitter(' ').array[1][0..8];
    auto timestamp = "[" ~ now ~ "] ";
    cwritefln(timestamp ~ fmt, vs);
  }

  void onNewRootTestSuite(string ts)
  {
    log("New root test suite: '%s'".color(fg.yellow), ts);
  }

  void onNewTestSuite(string ts, string parentTs)
  {
    log(
      "New test suite: '%s' (came from %s)".color(fg.yellow),
      ts,
      parentTs
    );
  }

  void onNewSerialTestCase(SerialTestCase tc)
  {
    log("New serial test case: '%s'".color(fg.yellow), tc.title);
  }

  void onNewParallelTestCase(ParallelTestCase tc)
  {
    log("New parallel test case '%s'".color(fg.magenta), tc.title);
  }

  void onTestCaseFailure(TestCaseFailure tc)
  {
    log("New test case failure: '%s'".color(fg.red), tc.title);
    log("   ERROR: '%s'".color(fg.red), tc.msg);
    log("   INFO:\n%s".color(fg.red), tc.info);
  }

  void onTestCaseSuccess(TestCaseResult tc)
  {
    log("New test case success: '%s'".color(fg.green), tc.title);
  }
}
