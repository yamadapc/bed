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

  import colorize : cwrite, cwriteln, cwritefln, fg, color;

  alias Tuple!(string, Throwable) Failure;
  alias Tuple!(int, int) Point;

  version(Windows)
  {
    static immutable string succeeded = "[P] ".color(fg.green);
    static immutable string failed = "[F] ".color(fg.red);
    static immutable string pending = "[?] ".color(fg.yellow);
  }
  else
  {
    static immutable string succeeded = "✓ ".color(fg.green);
    static immutable string failed = "✖︎ ".color(fg.red);
    static immutable string pending = "● ".color(fg.yellow);
  }

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
    cwriteln(indent ~ suite.title);
    height++;

    auto cindent = indent ~ "  ";

    foreach(spec; suite.specs)
    {
      specPositions[spec.title] = Point(cindent.length.to!int, height);
      attachListener(spec);

      cwriteln(cindent, pending, spec.title.color(fg.light_black));
      height++;
      ntests++;
    }

    foreach(s; suite.suites) draw(s, cindent);

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

    auto pos = specPositions[specTitle];

    version(Windows)
    {
      import std.c.windows.windows;
      // What is our HWND?
      auto hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
      // save cursor position
      CONSOLE_SCREEN_BUFFER_INFO SBInfo;
      hConsole.GetConsoleScreenBufferInfo(&SBInfo);
      auto prevCoords = SBInfo.dwCursorPosition;
      // Move to edit old line
      auto lPos = prevCoords.Y - (height - pos[1]);
      hConsole.SetConsoleCursorPosition(COORD(0, cast(short)lPos));
      // delete line contents
      foreach(i; 0 .. SBInfo.dwSize.X)
        write("\b");
      hConsole.SetConsoleCursorPosition(COORD(0, cast(short)lPos));
    }
    else
    {
      write("\033[s"); // save cursor position
      writef("\033[%dA", height - pos[1]);
      write("\033[K"); // delete until the end of the line
    }

    auto indent = "";
    for(auto i = 0; i < pos[0]; i++) indent ~= " ";
    
    if(e is null)
    {
      nsucceeded++;
      cwrite(indent, succeeded, specTitle.color(fg.light_black));
    }
    else
    {
      app.put(Failure(specTitle, e));
      nfailed++;
      cwrite(indent, color(nfailed.to!string ~ ") " ~  specTitle, fg.red));
    }

    version(Windows)
    {
      hConsole.SetConsoleCursorPosition(prevCoords);
    }
    else
      write("\033[u"); // return to where we were
    
    // We are done, print summary
    if(nsucceeded + nfailed == ntests) summary();
  }

  void summary()
  {
    if(nsucceeded > 0) cwritefln("%3d passing".color(fg.green), nsucceeded);
    if(nfailed > 0)
    {
      cwritefln("%3d failing".color(fg.red), nfailed);
      writeln();
    }

    foreach(i, failure; failures)
    {
      auto title = failure[0];
      auto e = failure[1];
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
