// Test data structures
module bed.tests;

import std.functional : partial;
import std.traits : isSomeFunction;
import std.typecons : Tuple;

alias Block = void delegate();
alias ParallelBlock = void function();

struct SerialTestCase
{
  string title;
  Block block;
}

struct ParallelTestCase
{
  string title;
  ParallelBlock block;
}

struct TestSuite
{
  immutable string title;

  TestSuite[] testSuites;
  SerialTestCase[] serialTestCases;
  ParallelTestCase[] parallelTestCases;

  void add(TestSuite ts) { testSuites ~= ts; }
  void add(SerialTestCase tc) { serialTestCases ~= tc; }
  void add(ParallelTestCase tc) { parallelTestCases ~= tc; }
}

template isTest(T)
{
  static if(is(T == TestSuite) || is(T == SerialTestCase) ||
            is(T == ParallelTestCase))
  {
    enum bool isTest = true;
  }
  else
  {
    enum bool isTest = false;
  }
}
