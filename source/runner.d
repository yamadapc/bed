import core.thread;

import testsuite;
import settings;

static TestSuite currentsuite;
static Reporter reporter;

void describe(string title, Block block)
{
  auto testsuite = new TestSuite(title, block);
  if(currentsuite is null) 
  {
    testsuite.isRoot = true;
    reporter = newReporter(testsuite);
  }
  else currentsuite.addTestSuite(testsuite);

  currentsuite = testsuite;
  testsuite.block();
  testsuite.run();
  reporter.summary();
}

void it(string title, Block block)
{
  auto testcase = TestCase(title, block);
  currentsuite.addTestCase(testcase);
}

unittest
{
  import std.stdio;

  describe("Something", {
    it("second", {
      writeln("start 'second'");
      Thread.sleep(2000.msecs);
      writeln("done 'second'");
    });

    it("first", {
      writeln("start 'first'");
      Thread.sleep(1000.msecs);
      writeln("done 'first'");
    });
  });
}

interface Reporter
{
  void onTestCaseEnd(TestCase testcase);
  void summary();
}

class SpecReporter : Reporter
{
  import std.conv : to;
  import std.regex : replaceAll, regex;
  import std.stdio : writeln, writefln, writef, write;

  import colorize : cwrite, cwriteln, cwritefln, fg, color;

  static immutable string succeeded = "✓ ".color(fg.green);
  static immutable string failed = "✖︎ ".color(fg.red);
  static immutable string pending = "● ".color(fg.yellow);

  uint nsucceeded = 0;
  uint nfailed = 0;

  TestSuite testsuite;
  TestCase[] failures;

  this(TestSuite _testsuite)
  {
    testsuite = _testsuite;
  }

  void onTestCaseEnd(TestCase testcase)
  {
    if(testcase.failed) cwriteln("Test failed.".color(fg.red));
    else cwriteln("Test passed.".color(fg.green));
  }

  void draw(TestSuite testsuite, const string indent = "  ")
  {
    cwriteln(indent ~ testsuite.title);
    auto cindent = indent ~ "  ";

    foreach(testcase; testsuite.testcases)
    {
      if(testcase.failed)
      {
        nfailed++;
        failures ~= testcase;
        cwriteln(cindent, failed, testcase.title.color(fg.light_black));
      }
      else
      {
        nsucceeded++;
        cwriteln(cindent, succeeded, testcase.title.color(fg.light_black));
      }
    }

    foreach(s; testsuite.testsuites) draw(s, cindent);
    if(testsuite.isRoot) writeln();
  }

  void summary()
  {
    draw(testsuite);

    if(nsucceeded > 0) cwritefln("%3d passing".color(fg.green), nsucceeded);
    if(nfailed > 0)
    {
      cwritefln("%3d failing".color(fg.red), nfailed);
      writeln();
    }

    foreach(i, failure; failures)
    {
      auto title = failure.title;
      auto e = failure.err;
      cwritefln("%3d) %s:", ++i, title);
      cwritefln(
        "     %s %s",
        e.msg.color(fg.red),
        (e.file ~ "L" ~ e.line.to!string).color(fg.magenta)
      );
      cwritefln(
        "     %s",
        replaceAll(e.info.to!string, regex("\n"), "\n     ")
        .color(fg.light_black)
      );
    }

    writeln();
  }
}
