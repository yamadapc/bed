import runnable;
import suite;
import spec;

class Reporter
{
  this(Suite suite);
}

class SpecReporter
{
  import std.array : RefAppender, appender;
  import std.conv : to;
  import std.regex : replaceAll, regex;
  import std.stdio : writeln, writefln, writef, write;
  import std.typecons : Tuple;

  import colorize : colorize, fg;

  alias Tuple!(string, Throwable) Failure;
  alias Tuple!(int, int) Point;

  static immutable string succeeded = "✓ ".colorize(fg.green);
  static immutable string failed = "✖︎ ".colorize(fg.red);
  static immutable string pending = "● ".colorize(fg.yellow);

  Failure[] failures;
  RefAppender!(Failure[]) app;
  Point[string] specPositions;
  int height;
  int ntests;
  int nfailed;
  int nsucceeded;

  this(Suite suite)
  {
    failures = [];
    app = appender(&failures);
    draw(suite);
  }

  void draw(Suite suite, const string indent = "  ")
  {
    writeln(indent ~ suite.title);
    height++;

    auto cindent = indent ~ "  ";

    foreach(spec; suite.specs)
    {
      specPositions[spec.title] = Point(cindent.length.to!int, height);
      attachListener(spec);

      writeln(cindent, pending, spec.title.colorize(fg.light_black));
      height++;
      ntests++;
    }

    foreach(child; suite.children) draw(child, cindent);

    if(suite.isRoot)
    {
      writeln();
      height++;
    }
  }

  void attachListener(Spec spec)
  {
    spec.connect(&updateSpec);
  }

  void updateSpec(string specTitle, Throwable e)
  {

    write("\033[s"); // save cursor position

    auto pos = specPositions[specTitle];

    writef("\033[%dA", height - pos[1]);
    write("\033[K"); // delete until the end of the line

    auto indent = "";
    for(auto i = 0; i < pos[0]; i++) indent ~= " ";

    if(e is null)
    {
      nsucceeded++;
      write(indent, succeeded, specTitle.colorize(fg.light_black));
    }
    else
    {
      app.put(Failure(specTitle, e));
      nfailed++;
      write(indent, colorize(nfailed.to!string ~ ") " ~  specTitle, fg.red));
    }

    write("\033[u"); // return to where we were

    // We are done, print summary
    if(nsucceeded + nfailed == ntests) summary();
  }

  void summary()
  {
    writefln("%3d passing".colorize(fg.green), nsucceeded);
    writefln("%3d failing".colorize(fg.red), nfailed);
    writeln();

    foreach(i, failure; failures)
    {
      auto title = failure[0];
      auto e = failure[1];
      writefln("%3d) %s:", ++i, title);
      writefln(
        "     %s %s",
        e.msg.colorize(fg.red),
        (e.file ~ "L" ~ e.line.to!string).colorize(fg.magenta)
      );
      writefln(
        "     %s",
        replaceAll(e.info.to!string, regex("\n"), "\n     ")
        .colorize(fg.light_black)
      );
    }

    writeln();
  }
}
