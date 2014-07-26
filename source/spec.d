import runnable;
import suite;

alias void delegate() SpecBlock;

class Spec : Runnable
{
  SpecBlock block;

  this(const string title, Suite suite, SpecBlock _block)
  {
    block = _block;
    super(title, suite);
  }

  override void run()
  {
    Throwable e = null;
    try block();
    catch(Throwable e_) e = e_;
    end(e);
  }

  unittest
  {
    import bed : describe, Suite;

    describe("Spec", (t) {
      auto mockparent = new Suite("mock suite");

      t.describe("this(title, suite, block)", (t) {
        t.it("returns a normal spec, without executing the block", {
          auto called = false;
          auto spec = new Spec("test spec", mockparent, { called = true; });
          assert(!called);
        });
      });

      t.describe(".run()", (t) {
        t.it("works when the delegate succeeds", {
          auto called = false;
          auto spec = new Spec("ok", mockparent, { called = true; });
          spec.run;
          assert(called);
        });

        t.it("works when the delegate fails", {
          auto spec = new Spec("test failure", mockparent, {
            throw new Exception("Wow");
          });
          spec.run();

          spec = new Spec(
            "test failure",
            mockparent,
            {
              throw new Error("Such");
            }
          );
          spec.run();
        });
      });
    });
  }
}
