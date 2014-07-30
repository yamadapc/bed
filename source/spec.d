import runnable;
import suite;

class Spec : Runnable
{
  Block block;

  this(const string title, Suite suite, Block _block)
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
    import bed : describe, it, Suite;

    describe("Spec", {
      auto mockparent = new Suite("mock suite");

      describe("this(title, suite, block)", {
        it("returns a normal spec, without executing the block", {
          auto called = false;
          auto spec = new Spec("test spec", mockparent, { called = true; });
          assert(!called);
        });
      });

      describe(".run()", {
        it("works when the delegate succeeds", {
          auto called = false;
          auto spec = new Spec("ok", mockparent, { called = true; });
          spec.run;
          assert(called);
        });

        it("works when the delegate fails", {
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
