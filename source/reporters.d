import std.conv : to;
import std.typecons : Tuple;

import context;
import runnable;

class Reporter
{
  this(Context context);
}

class SpecReporter
{
  import std.stdio : writeln, writefln, writef, write;
  import colorize : colorize, fg;

  alias Tuple!(int, int) Point;

  static immutable string succeeded = "✓ ".colorize(fg.green);
  static immutable string failed = "✖︎ ".colorize(fg.red);
  static immutable string pending = "● ".colorize(fg.yellow);

  Point[string] specPositions;
  int height;
  int ntests;
  int nfailed;
  int nsucceeded;

  this(Context context)
  {
    writeln("\nRunning tests\n");
    draw(context);
  }

  void draw(Context context, const string indent = "  ")
  {
    writeln(indent ~ context.title);
    height++;

    auto cindent = indent ~ "  ";

    foreach(spec; context.specs)
    {
      specPositions[spec.title] = Point(cindent.length.to!int, height);
      attachListener(spec);

      writeln(cindent, pending, spec.title.colorize(fg.light_black));
      height++;
      ntests++;
    }

    foreach(child; context.children) draw(child, cindent);

    if(context.isRoot)
    {
      writeln();
      height++;
    }
  }

  void attachListener(Spec spec)
  {
    spec.addListener(
      (e) => updateSpec(spec.title, (e is null))
    );
  }

  void updateSpec(string specTitle, bool ok)
  {
    write("\033[s"); // save cursor position

    auto pos = specPositions[specTitle];

    writef("\033[%dA", height - pos[1]);
    write("\033[K"); // delete until the end of the line

    auto indent = "";
    for(auto i = 0; i < pos[0]; i++) indent ~= " ";

    if(ok)
    {
      nsucceeded++;
      write(indent, succeeded, specTitle.colorize(fg.light_black));
    }
    else
    {
      nfailed++;
      write(indent, failed, specTitle.colorize(fg.red));
    }

    write("\033[u"); // return to where we were

    // We are done, print summary
    if(nsucceeded + nfailed == ntests)
    {
      writefln("  %d passing".colorize(fg.green), nsucceeded);
      writefln("  %d failing".colorize(fg.red), nfailed);
      writeln();
    }
  }
}
