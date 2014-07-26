module test.spec;
unittest
{
  import bed : describe, Suite, Spec;

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
