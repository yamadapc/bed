import std.exception : collectException, AssertError;

alias void delegate(Throwable e) Listener;
alias void delegate(Runnable) Block;

class Runnable
{
  bool failed = false;
  string title;
  Runnable parent;
  Listener[] listeners;

  final this(const string title_, Runnable parent_)
  {
    title = title_;
    parent = parent_;
  }

  void addListener(Listener listener)
  {
    listeners ~= listener;
  }

  void propagateFailure()
  {
    auto next = parent;

    while(next)
    {
      next.failed = true;
      next = next.parent;
    }
  }

  void end(Throwable e)
  {
    foreach(listener; listeners) listener(e);
  }

  abstract void run();
}
