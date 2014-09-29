
int sum(int x, int y) {
  return x + y;
}

unittest {
  import bed;
  import pyjamas;

  import std.stdio;
  describe("sum(x, y)", {
    it("returns the sum of two integers", {
      sum(1, 2).should.equal(3);
    });
  });
}
