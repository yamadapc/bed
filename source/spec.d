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
}
