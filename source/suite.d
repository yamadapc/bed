import runnable;
import spec;

alias void delegate(Suite) SuiteBlock;

class Suite : Runnable
{
  bool isRoot = false;
  Suite[] children;
  Spec[] specs;

  this(const string title, ref Suite parent)
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

  unittest
  {
    int called = 0;

    auto t = new Suite("Testing");

    t.it("Aw", (t) { called++; });
    t.it("Such wow", (t) { called++; });
    t.it("Much it", (t) { called++; });

    t.describe("I'm nested", (t) {
      t.it("And a infinite-branch tree structure", (t) {
        called++;
      });
    });

    assert(t.isRoot);
    assert(t.title == "Testing");
    assert(t.children.length == 1);
    assert(t.specs.length == 3);
    assert(t.children[0].title == "I'm nested");

    auto child = t.children[0];
    assert(!child.isRoot);
    assert(child.children.length == 0);
    assert(child.specs.length == 1);

    t.run;

    assert(called == 4);
    called = 0;
    child.run;

    assert(called == 1);
  }
}
