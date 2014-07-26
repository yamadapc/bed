import suite;
import reporters;
import runnable;

void describe(R = SpecReporter)(string title, SuiteBlock block)
{
  auto suite = new Suite(title);
  block(suite);

  auto rep = new R(suite);
  suite.run();

  assert(!suite.failed, "One or more tests failed");
}

unittest
{
  import std.stdio;

  int add(int x, int y)
  {
    return x + y;
  }

  describe("add(x, y)", (t) { t
    .it("1 + 3 = 4", (t) {
      assert(add(1, 3) == 4);
    })

    .it("1 + 10 = 4", (t) {
      assert(add(1, 10) == 11);
    })

    /*
    .it("2 + 2 = 5", (t) {
      assert(add(2, 2) == 5, "what the hell happened?");
    })
    */

    .describe("when x is a negative number", (t) { t
      .it("-10 + 2 = -8", (t) {
        assert(add(-10, 2) == -8);
      });

      /*
      .it("-2 - 2 = -5", (t) {
        assert(add(-2, -2) == -5, "oh my!");
      });
      */
    });
  });
}
