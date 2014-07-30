import runnable;
import spec;

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

  unittest
  {
    import bed : describe, it, Suite;

    describe("Suite", {
      describe("this(title)", {
        it("returns a named unparented suite", {
          auto suite = new Suite("Root Suite");
        });
      });

      describe("this(title, parent)", {
        it("returns a named child suite", {
          auto parent = new Suite("Root Suite");
          auto suite = new Suite("Testing", parent);

          assert(suite.title == "Testing");
          assert(suite.parent == parent);
        });
      });

      describe(".isRoot", {
        it("returns true if the suite is parentless", {
          assert(new Suite("root").isRoot);
        });

        it("returns false if the suite is a child", {
          assert(!(new Suite("child", new Suite("root")).isRoot));
        });
      });
    });
  }
}
