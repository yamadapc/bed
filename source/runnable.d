import std.signals;
import std.exception : collectException, AssertError;

alias void delegate(Runnable) Block;

class Runnable
{
  bool failed = false;
  string title;
  Runnable parent;

  final this(const string _title, Runnable _parent)
  {
    title = _title;
    parent = _parent;
  }

  void propagateFailure(string title, Throwable e)
  {
    if(e is null) return;

    auto next = parent;
    while(next)
    {
      next.failed = true;
      next = next.parent;
    }
  }

  void end(Throwable e)
  {
    emit(title, e);
  }

  abstract void run();

  mixin Signal!(string, Throwable);
}
