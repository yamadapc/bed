import std.exception : collectException;
import std.stdio;

import runnable;

alias void delegate(Spec) SpecBlock;
alias void delegate(Context) ContextBlock;

class Spec : Runnable
{
  SpecBlock block;

  this(const string title_, ref Context context_, SpecBlock block_)
  {
    block = block_;
    super(title_, context_);
  }

  override void run()
  {
    Throwable e = null;
    try block(this);
    catch(Throwable e_) e = e_;
    end(e);
  }

  unittest
  {
    auto parent = new Context("mock context");
    Spec spec;

    // test success
    auto testRan = false;
    spec = new Spec("test success", parent, (t) { testRan = true; });
    spec.run();
    assert(testRan, "Test didn't ran");

    // test exception
    spec = new Spec(
      "test failure",
      parent,
      (t) {
        throw new Exception("Wow");
      }
    );
    spec.run();

    // test error
    spec = new Spec(
      "test failure",
      parent,
      (t) {
        throw new Error("Such");
      }
    );
    spec.run();
  }
}

class Context : Runnable
{
  bool isRoot = false;
  Context[] children;
  Spec[] specs;

  this(const string title_, ref Context parent_)
  {
    super(title_, parent_);
  }

  this(const string title_)
  {
    isRoot = true;
    super(title_, null);
  }

  override void run()
  {
    foreach(Spec spec; specs)
    {
      spec.run;
    }

    foreach(Context child; children)
    {
      child.run;
    }
  }

  Context describe(const string title, ContextBlock block)
  {
    auto context = new Context(title, this);
    children ~= context;
    block(context);
    return this;
  }

  Context it(const string title, SpecBlock block)
  {
    auto spec = new Spec(title, this, block);
    spec.connect(&propagateFailure);
    specs ~= spec;
    return this;
  }

  unittest
  {
    int called = 0;

    auto t = new Context("Testing");

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
