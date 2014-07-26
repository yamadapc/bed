module test.suite;
unittest
{
  import bed : describe, Suite;

  describe("Suite", (t) {
    t.describe("this(title)", (t) {
      t.it("returns a named unparented suite", {
        auto suite = new Suite("Root Suite");
      });
    });

    t.describe("this(title, parent)", (t) {
      t.it("returns a named child suite", {
        auto parent = new Suite("Root Suite");
        auto suite = new Suite("Testing", parent);

        assert(suite.title == "Testing");
        assert(suite.parent == parent);
      });
    });

    t.describe(".isRoot", (t) {
      t.it("returns true if the suite is parentless", {
        assert(new Suite("root").isRoot);
      });

      t.it("returns false if the suite is a child", {
        assert(!(new Suite("child", new Suite("root")).isRoot));
      });
    });

    t.describe(".describe(title, block)", (t) {
      t.it("loads new blocks, registering other specs and suites", {
        Suite suite = new Suite("Testing");
        Suite childSuite;
        auto called = false;
        suite.describe("I'm nested", (t) {
          childSuite = t;
          t.it("And a infinite-branch tree structure", {
            called = true;
          });
        });
        assert(called == false);
        assert(!(childSuite is null));
        assert(suite.children.length == 1);
        assert(suite.children[0] == childSuite);
        assert(childSuite.specs.length == 1);
      });
    });

    t.describe(".it(title, block)", (t) {
      t.it("schedules the block for execution in the Suite", {
        auto suite = new Suite("Root Suite");
        auto called = false;
        suite.it("as", { called = true; });
        suite.it("bs", { called = true; });
        suite.it("cs", { called = true; });
        assert(called == false);
        assert(suite.specs.length == 3);
      });
    });
  });
}
