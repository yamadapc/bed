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
  import std.stdio : writeln, writef;
  import colorize : colorize, fg;

  alias Tuple!(int, int) Point;

  static immutable string succeeded = "✓ ".colorize(fg.green);
  static immutable string failed = "✖︎ ".colorize(fg.red);
  static immutable string pending = "● ".colorize(fg.yellow);

  Point[string] specPositions;
  int height;

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
    }

    foreach(child; context.children) draw(child, cindent);

    if(context.isRoot) writeln();
  }

  void attachListener(Spec spec)
  {
    spec.addListener(
      (e) => updateSpec(spec.title, (e is null))
    );
  }

  void updateSpec(string specTitle, bool succeeded)
  {
    // todo
  }
}
