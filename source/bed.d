import context;
import reporter;
import runnable;

void describe(R = SpecReporter)(string title, ContextBlock block)
{
  auto context = new Context(title);
  block(context);

  new R(context);
  context.run();
}

unittest
{
  import std.stdio;

  int add(int x, int y)
  {
    return x + y;
  }

  describe("add(x, y)", (t) {
    t.it("1 + 3 = 4", (t) {
      assert(add(1, 3) == 4);
    });

    t.it("1 + 10 = 4", (t) {
      assert(add(1, 10) == 11);
    });

    t.it("2 + 2 = 5", (t) {
      assert(add(2, 2) == 5);
    });

    t.describe("when x is a negative number", (t) {
      t.it("-10 + 2 = -8", (t) {
        assert(add(-10, 2) == -8);
      });
    });
  });
}
