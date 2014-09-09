/**
 * Eager threaded TestCase runner.
 */

module bed.runner;

import std.concurrency;
import std.parallelism;
import std.stdio;
import core.thread;

import bed.tests;
import colorize;

alias object.Throwable.TraceInfo TraceInfo;

/**
 * Result data type. If a result isn't a failure, it's a assumed to be
 * a success.
 */

struct TestCaseResult
{
  string title;
}

/**
 * Failure data type. Aliases to the default result struct, retaining
 * its fields and interface.
 */

struct TestCaseFailure
{
  string msg;
  string info;
  string file;
  size_t line;

  TestCaseResult rs;
  alias rs this;
}

/**
 * Starts the runner loop, which keeps spawning contexts for incoming test
 * cases and letting the test cases reply at requesters.
 */

void startRunner()
{
  auto running = true;
  while(running)
  {
    receive(
      // Spawn independent context for running and replying to the message
      (Tid tid, ParallelTestCase tc) => spawn(&runTestCase, tid, tc),

      // Shut down if the owner stops
      // (This function needs to be void. I'm not sure if this is a bug)
      (OwnerTerminated _) { running = false; }
    );
  }
}

/**
 * Executes a test case `tc`, sending a failure or success back to owner `tid`.
 */

private void runTestCase(Tid owner, ParallelTestCase tc)
{
  try
  {
    tc.block();
    owner.send(
      TestCaseResult(tc.title)
    );
  }
  catch(Throwable err)
  {
    owner.send(
      TestCaseFailure(err.msg, err.info.toString(), err.file, err.line,
        TestCaseResult(tc.title))
    );
  }
}

unittest
{
  import pyjamas;

  Tid tid = spawn(&startRunner);

  auto tc1 = ParallelTestCase("Slow and buggy", {
    Thread.sleep(200.msecs);
    assert(false, "Ooops...!");
  });
  send(tid, thisTid, tc1);

  auto tc2 = ParallelTestCase("Fast and awesome", {
    assert(true);
  });
  send(tid, thisTid, tc2);

  // We should receive a TestCaseResult from tc2 first
  receive(
    (TestCaseResult result) {
      result.title.should.equal("Fast and awesome");
    }
  );

  // We should now receive a TestCaseFailure from tc1
  receive(
    (TestCaseFailure result) {
      result.title.should.equal("Slow and buggy");
    },
    (TestCaseResult _) {
      assert(false, "TestCaseFailure wasn't sent");
    }
  );
}
