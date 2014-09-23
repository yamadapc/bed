import runnable;
import spec;

class Suite : Runnable
{
  bool isRoot = false;
  Suite[] suites;
  Spec[] specs;

  Block[] befores;
  Block[] beforeEachs;
  Block[] afters;
  Block[] afterEachs;

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
    foreach(before; befores) before();
    scope(exit) foreach(after; afters) after();
    foreach(Spec spec; specs) runChild(spec);
    foreach(Suite suite; suites) runChild(suite);
  }

  private void runChild(T)(T child)
  {
    foreach(before; beforeEachs) before();
    scope(exit) foreach(after; afterEachs) after();
    child.run;
  }

  version(BED_SELFTEST)
  unittest
  {
    import bed : describe, it, before, after, beforeEach, afterEach, Suite;

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
        it("is true if the suite is parentless", {
          assert(new Suite("root").isRoot);
        });

        it("is false if the suite is a child", {
          assert(!(new Suite("child", new Suite("root")).isRoot));
        });
      });

      describe("Member before/after family blocks", {
        Suite rootsuite;
        beforeEach({
          rootsuite = new Suite("Root Suite");
        });

        it("starts uninitialized", {
          assert(rootsuite.befores.length == 0);
          assert(rootsuite.afters.length == 0);
          assert(rootsuite.beforeEachs.length == 0);
          assert(rootsuite.afterEachs.length == 0);
        });

        it("runs `befores` in order before all 'child' blocks", {
          auto ran1 = false;
          auto ran2 = false;

          rootsuite.befores = [
            { assert(!ran2); ran1 = true; },
            { ran2 = true; }
          ];
          assert(rootsuite.suites.length == 0);
          assert(rootsuite.specs.length == 0);

          rootsuite.run;
          assert(ran1);
          assert(ran2);
        });
      });
    });
  }
}
