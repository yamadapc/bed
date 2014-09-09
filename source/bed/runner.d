// Test suite/case runner
module bed.runner;

import std.concurrency;
import std.parallelism;
import std.stdio;
import core.thread;

import bed.tests;
import colorize;

/**
 * Immutable result data type. If a result isn't a failure, it's a assumed to be
 * a success.
 */

struct TestCaseResult
{
  immutable string title;
}

/**
 * Immutable failure data type. Aliases to the default result struct, retaining
 * its fields and interface.
 */

struct TestCaseFailure
{
  immutable string msg;
  immutable object.Throwable.TraceInfo info;
  immutable string file;
  immutable size_t line;

  immutable TestCaseResult rs;
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

private void runTestCase(Tid tid, ParallelTestCase tc)
{
  try
  {
    tc.block();
    send(tid, tc.title, true);
  }
  catch(Throwable err)
  {
    send(tid, ImmutableError(err.msg.idup, err.info.assumeImmutable, err.file, err.line));
  }
}

unittest
{
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

  receive(
    (string title, string msg) =>
      cwritefln("%s\n%s".color(fg.red), title, msg),
    (string title, bool ok) =>
      cwriteln(title.color(fg.green))
  );

  receive(
    (string title, string msg) =>
      cwritefln("%s\n%s".color(fg.red), title, msg),
    (string title, bool ok) =>
      cwriteln(title.color(fg.green))
  );
}
