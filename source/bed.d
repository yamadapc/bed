module bed;

import std.algorithm;
import std.array;
import std.concurrency;
import std.parallelism;
import std.typecons;
import std.signals;

import core.thread;

import testsuite;
import runner;

unittest
{
  import std.stdio;

  auto testsuite = new TestSuite("Something", {});
  auto testcase = TestCase("nested", {
    writeln("Start 1");
    Thread.sleep(1000.msecs);
    writeln("Done 1");
  });
  testsuite.addTestCase(testcase);

  auto testcase2 = TestCase("nested 2", {
    writeln("Start 2");
    Thread.sleep(2000.msecs);
    writeln("Done 2");
  });
  testsuite.addTestCase(testcase2);

  writeln("Starting to run test suite");
  testsuite.run();
  writeln("Done running");
}

