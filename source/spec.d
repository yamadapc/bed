import runnable;
import suite;

alias void delegate(Spec) SpecBlock;

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
    try block(this);
    catch(Throwable e_) e = e_;
    end(e);
  }

  unittest
  {
    auto parent = new Suite("mock suite");
    Spec spec;

    // test success
    auto testRan = false;
    spec = new Spec("test success", parent, (t) { testRan = true; });
    spec.run();
    assert(testRan, "Test didn't ran");

    // test exception
    spec = new Spec(
      "test failure",
      parent,
      (t) {
        throw new Exception("Wow");
      }
    );
    spec.run();

    // test error
    spec = new Spec(
      "test failure",
      parent,
      (t) {
        throw new Error("Such");
      }
    );
    spec.run();
  }
}
