import runnable;
import spec;

version(unittest) import test.suite;

alias void delegate(Suite) SuiteBlock;

class Suite : Runnable
{
  bool isRoot = false;
  Suite[] children;
  Spec[] specs;

  this(const string title, Suite parent)
  {
    super(title, parent);
  }

  this(const string title)
  {
    isRoot = true;
    super(title, null);
  }

  override void run()
  {
    foreach(Spec spec; specs)
    {
      spec.run;
    }

    foreach(Suite child; children)
    {
      child.run;
    }
  }

  Suite describe(const string title, SuiteBlock block)
  {
    auto suite = new Suite(title, this);
    children ~= suite;
    block(suite);
    return this;
  }

  Suite it(const string title, SpecBlock block)
  {
    auto spec = new Spec(title, this, block);
    spec.connect(&propagateFailure);
    specs ~= spec;
    return this;
  }

}
