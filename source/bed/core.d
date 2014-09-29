/**
 * Core bed module. Delegates loading, running and reporting across runner and
 * reporter threads.
 */

module bed.core;

import std.algorithm : map;
import std.array : array;
import std.concurrency : Tid, send, spawn;
import std.traits : isDelegate, isSomeFunction;
import core.thread;

public import pyjamas;
import bed.tests;
import bed.runner;
import bed.reporter;

/**
 * Runner thread id, for delegating test suite/case execution.
 */

static Tid runner;
static Tid[] reporters;

/**
 * Configuration value. Shouldn't be exposed raw.
 */

private static BedConfig bedConfig;
void useConfig(BedConfig _config)
{
  bedConfig = _config;
}

static struct BedConfig
{
  bool eagerRun = true;
  bool parallelize = true;
  Reporter[] reporters = [];
}

/**
 * Bed constructor. Starts the runner thread, waiting for suites/cases to run.
 * If no spawnable test suite or test case is loaded, this will be wasted.
 */

shared static this()
{
  runner = spawn(&startRunner);
  reporters ~= spawn(&(new SpecReporter()).start);
}

/**
 * Points to the test suite which is currently being loaded. This is just so
 * that test loader interfaces (`describe`, `it` etc.) know where in the tree
 * Tests are.
 */

static TestSuite* currentTs;

/**
 * Helper for setting and unsetting the context's currently running test suite.
 */

private void withTestSuite(B)(ref TestSuite ts, B block)
  if(isSomeFunction!B)
{
  auto oldTs = currentTs;
  currentTs = &ts;
  block();
  currentTs = oldTs;
}

/**
 * Takes a title and a block, creates a TestSuite and loads it. This will
 * already run its test cases.  Concurrency is archieved as much as the `block`
 * function allows.
 */

void addTestSuite(immutable string title, Block block)
{
  auto ts = TestSuite(title);

  if(currentTs !is null) notifyReporters(ts.title, (*currentTs).title);
  else notifyReporters(ts.title);

  withTestSuite(ts, block);
}

unittest
{
  import std.algorithm : map;
  import std.array : array;
  import pyjamas;

  auto executed = false;
  addTestSuite("Something", {
    (*currentTs).title.should.equal("Something");
    addTestSuite("Else", {
      executed = true;
      (*currentTs).title.should.equal("Else");
    });
    (*currentTs).title.should.equal("Something");
  });

  executed.should.be.True;
}

/**
 * Takes a title and a block, creates a test case and decides whether to run it
 * in the current thread, or to delegate it to the runner thread.
 */

void addTestCase(F)(immutable string title, F block)
{
  auto tc = TestCase!F(title, block);
  (*currentTs).add(tc);

  notifyReporters(tc);

  static if(is(typeof(tc) == ParallelTestCase))
  {
    runner.send(reporters[0], tc);
  }
  else
  {
    try
    {
      tc.block();
      notifyReporters(
        TestCaseResult(tc.title)
      );
    }
    catch(Throwable err)
    {
      notifyReporters(
        TestCaseFailure(err.msg, err.info.toString(), err.file, err.line,
          TestCaseResult(tc.title))
      );
    }
  }
}

/**
 * Sends all reporters some message.
 */

void notifyReporters(T...)(T xs)
{
  foreach(reporter; reporters) reporter.send(xs);
}
