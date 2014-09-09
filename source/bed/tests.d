// Test data structures
module bed.tests;

import std.functional : partial;
import std.traits : isSomeFunction;
import std.typecons : Tuple;

alias Block = void delegate();
alias ParallelBlock = void function();

struct TestCase(F)
  if(isSomeFunction!F)
{
  string title;
  F block;
}

alias SerialTestCase = TestCase!Block;
alias ParallelTestCase = TestCase!ParallelBlock;

struct TestSuite
{
  immutable string title;

  TestSuite*[] testSuites;
  SerialTestCase*[] serialTestCases;
  ParallelTestCase*[] parallelTestCases;

  void add(ref TestSuite ts) { testSuites ~= &ts; }
  void add(ref SerialTestCase tc) { serialTestCases ~= &tc; }
  void add(ref ParallelTestCase tc) { parallelTestCases ~= &tc; }
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
