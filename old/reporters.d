module bed.reporters;

import bed.tests;

interface Reporter
{
  void listen(TestSuite rootTs);
  void onTestCaseEnd(string title, Throwable err);
  void summary();
}

class SpecReporter : Reporter
{
  this() {}

  // The spec reporter is a summary only reporter, so its `onTestCaseEnd`
  // function is a noop (TODO - let bed be either parallel or serial)
  void onTestCaseEnd(string title, Throwable err) {}

  void listen(TestSuite _ts)
  {
    ts = _ts;
  }

  void summary()
  {
    draw(ts);

    if(nsucceeded > 0) cwritefln("%3d passing".color(fg.green), nsucceeded);
    if(nfailed > 0)
    {
      cwritefln("%3d failing".color(fg.red), nfailed);
      writeln();
    }

    foreach(i, tc; failedTcs)
    {
      auto title = tc.title;
      auto e = tc.err;
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

private:
  import std.conv : to;
  import std.regex : replaceAll, regex;
  import std.stdio : writeln, writefln, writef, write;

  import colorize : cwrite, cwriteln, cwritefln, fg, color;

  static immutable string succeeded = "✓ ".color(fg.green);
  static immutable string failed = "✖︎ ".color(fg.red);
  static immutable string pending = "● ".color(fg.yellow);

  uint nsucceeded = 0;
  uint nfailed = 0;

  TestSuite ts;
  Failure[] failures;

  void draw(TestSuite ts, const string indent = "  ")
  {
    cwriteln(indent ~ ts.title);
    auto cindent = indent ~ "  ";

    foreach(tc; ts.testcases)
    {
      if(tc.failed)
      {
        nfailed++;
        failedTcs ~= tc;
        cwriteln(cindent, failed, tc.title.color(fg.light_black));
      }
      else
      {
        nsucceeded++;
        cwriteln(cindent, succeeded, tc.title.color(fg.light_black));
      }
    }

    foreach(s; ts.testsuites) draw(s, cindent);
    if(ts.isRoot) writeln();
  }
}
