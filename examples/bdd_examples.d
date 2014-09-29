
int sum(int x, int y) {
  return x + y;
}

unittest {
  import bed;
  import core.thread;
  import pyjamas;

  describe("sum(x, y)", {
    it("returns the sum of two integers", {
      sum(1, 2).should.equal(3);
      Thread.sleep(200.msecs);
    });
  });
}

int fibs(int x) {
  int[] fibs = [1, 1];
  auto i = 2;

  fibs.length = x;
  for(; i < x; i++) fibs[i] = fibs[i - 1] + fibs[i - 2];

  return fibs[x - 1];
}

unittest {
  import bed;
  import pyjamas;

  describe("fibs(x)", {
    it("returns the `x`th fibonacci number", {
      fibs(10).should.equal(55);
    });
  });
}
