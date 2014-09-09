/**
 * Reporter interface and thread starter.
 */

module bed.reporter;

import std.concurrency : OwnerTerminated, receive, Tid;

import bed.runner;
import bed.tests;

void startReporter(Reporter r)
{
  auto running = true;
  while(running)
  {
    receive(
      r.onNewTestSuite,
      r.onNewTestCase,
      r.onTestCaseFailure,
      r.onTestCaseSuccess,
      (OwnerTerminated _) { running = false; }
    );
  }
}

import std.stdio : writefln;
Reporter TextReporter = tuple(
  textReporterOnNewTestCase,

  void onTestCaseSuccess(TestCaseResult succ)
  {
    "TestCase %s passed".writefln(succ.title);
  },

  void onTestCaseFailure(TestCaseFailure fail)
  {
    "TestCase %s failed".writefln(fail.title);
  }
);

void textReporterOnNewTestCase(TestSuite ts)
{
  "TestSuite %s found".writefln(ts.title);
},


alias onNewTestSuite = void delegate(TestSuite);
alias onNewTestCase = void delegate(F)(F) if(isTest!F);
alias onTestCaseFailure = void delegate(TestCaseFailure);
alias onTestCaseSuccess = void delegate(TestCaseResult);
alias Reporter = Tuple!(
  onNewTestSuite, "onNewTestSuite",
  onNewTestCase, "onNewTestCase",
  onTestCaseFailure, "onTestCaseFailure",
  onTestCaseSuccess, "onTestCaseSuccess"
);

