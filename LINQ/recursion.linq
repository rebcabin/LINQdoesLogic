<Query Kind="Program">
  <Reference>&lt;ProgramFilesX86&gt;\Microsoft SDKs\Reactive Extensions\v2.0\Binaries\.NETFramework\v4.0\Microsoft.Reactive.Testing.dll</Reference>
  <Reference>&lt;ProgramFilesX86&gt;\Microsoft SDKs\Reactive Extensions\v2.0\Binaries\.NETFramework\v4.0\System.Reactive.Core.dll</Reference>
  <Reference>&lt;ProgramFilesX86&gt;\Microsoft SDKs\Reactive Extensions\v2.0\Binaries\.NETFramework\v4.0\System.Reactive.Interfaces.dll</Reference>
  <Reference>&lt;ProgramFilesX86&gt;\Microsoft SDKs\Reactive Extensions\v2.0\Binaries\.NETFramework\v4.0\System.Reactive.Linq.dll</Reference>
  <Reference>&lt;ProgramFilesX86&gt;\Microsoft SDKs\Reactive Extensions\v2.0\Binaries\.NETFramework\v4.0\System.Reactive.PlatformServices.dll</Reference>
  <Reference>&lt;ProgramFilesX86&gt;\Microsoft SDKs\Reactive Extensions\v2.0\Binaries\.NETFramework\v4.0\System.Reactive.Providers.dll</Reference>
  <Reference>&lt;ProgramFilesX86&gt;\Microsoft SDKs\Reactive Extensions\v2.0\Binaries\.NETFramework\v4.0\System.Reactive.Runtime.Remoting.dll</Reference>
  <Reference>&lt;ProgramFilesX86&gt;\Microsoft SDKs\Reactive Extensions\v2.0\Binaries\.NETFramework\v4.0\System.Reactive.Windows.Forms.dll</Reference>
  <Reference>&lt;ProgramFilesX86&gt;\Microsoft SDKs\Reactive Extensions\v2.0\Binaries\.NETFramework\v4.0\System.Reactive.Windows.Threading.dll</Reference>
  <Namespace>System.Reactive.Subjects</Namespace>
  <Namespace>System.Reactive.Linq</Namespace>
  <Namespace>System.Reactive</Namespace>
</Query>

void Main()
{
    var c1 = new @constant {Value = 4};
    
    // Non-LINQ method using recursive methods on classes
    // This is a transcription of 4 * (5 + 6) == 44
    new @binary {Left  = new @constant {Value = 4},
                 Op    = new @times(),
                 Right = new @binary {Left  = new @constant {Value = 5},
                                      Op    = new @plus(),
                                      Right = new @constant {Value = 6}}}
        .evaluate()
        .Dump("Non-LINQ method: expect 44")
        ;
        
    // LINQ method introduces one level of IEnumerable / IObservable
    var exprs = new [] { // Puts the expression in an IEnumerable<@expression>
        // The rest is as above
        new @binary {Left  = new @constant {Value = 4},
                     Op    = new @times(),
                     Right = new @binary {Left  = new @constant {Value = 5},
                                          Op    = new @plus(),
                                          Right = new @constant {Value = 6}}}};
                                          
    // The evaluator is now of type IEnumerable<@expression> to 
    // IEnumerable<int>, represented as a lambda expression
    // inside a Select (i.e., Map)
    
    exprs
        .Select(e => e.evaluate())
        .Dump("Bad LINQ method: expect IEnum of int containing 44")
        ;
    
    // oops!  The evaluator is of the WRONG TYPE!. We must make it
    // produce IEnumerable<@expression> and not IEnumerable<int>.  
    // We will have a different operator to "extract" values from 
    // an expression!
    
    // Let's create @expression::linqEvaluate and 
    // @operator::linqApply
    
    exprs
        .Select(e => e.linqEvaluate())
        .Dump("Good LINQ method: expect IEnum of @expression")
        ;
        
    // Now we can have some fun and generate a random expression
    @expression
        .generate()
        .Return()
        .Dump("Random Expression Tree")
        .Select(e => e.linqEvaluate())
        .Dump("Value of the Tree")
        ;
        
    // or a whole array of random expressions
    Enumerable
        .Range(0, 10)
        .Select(_ => @expression.generate())
        .Select(e => e.linqEvaluate())
        .Dump("Values of 10 random expression trees")
        ;
        
    // Reactive version
    Observable
        .Interval(TimeSpan.FromSeconds(1.0))
        .Take(10)
        .Select(_ => @expression.generate())
        .Subscribe(e => new {expression = e, value = e.linqEvaluate()}
            .Dump("A new expression every tick")
            );
}

public static class Extensions
{   public static IEnumerable<T> Return<T> (this T input)
    {   return new [] {input};   }
}
public abstract class @expression 
{   protected static Random random = new Random();
    protected static double[] probabilities = 
        new [] {40.0/100, 20.0/100, 20.0/100, 20.0/100};
    private static int randomIndex(double dieRoll, int index)
    {   if (dieRoll < probabilities[index])
            return index;
        return randomIndex(dieRoll - probabilities[index], index + 1);
    }
    public static @expression generate(int maxdepth = 6)
    {   var result = default (@expression);
        if (maxdepth < 0)
            return new @constant {Value = random.Next(99)};
        switch (randomIndex(random.NextDouble(), 0))
        {   case 0:
                result = new @constant {Value = random.Next(99)};
                break;
            case 1:
                result = new @binary {Left  = generate(maxdepth - 1),
                                      Op    = new @plus (),
                                      Right = generate(maxdepth - 1)};
                break;
            case 2:
                result = new @binary {Left  = generate(maxdepth - 1),
                                      Op    = new @times (),
                                      Right = generate(maxdepth - 1)};
                break;
            case 3:
                result = new @binary {Left  = generate(maxdepth - 1),
                                      Op    = new @minus (),
                                      Right = generate(maxdepth - 1)};
                break;
            default:
                throw new IndexOutOfRangeException();
        }
        return result;
    }
    public abstract int evaluate();
    public virtual int extract()
    {   throw new InvalidOperationException(
        "cannot extract a value from an arbitrary expression");   }
    public abstract @expression linqEvaluate();   }

public sealed class @constant : @expression
{   public int Value {get; set;}
    public override int extract ()
    {   return Value;   }
    public override int evaluate ()
    {   return Value;   }   
    public override @expression linqEvaluate ()
    {   return this;   }   
}

public sealed class @binary : @expression
{   public @expression Left  {get; set;}
    public @operator   Op    {get; set;}
    public @expression Right {get; set;}
    public override int evaluate ()
    {   return Op.apply(Left.evaluate(), Right.evaluate());   }   
    public override @expression linqEvaluate ()
    {   return Op.linqApply(Left.linqEvaluate(), Right.linqEvaluate());   }   
}

// These classes have no data: I really only need their virtual
// dispatch tables.
public abstract class @operator
{   public abstract int apply(int a, int b);   
    public abstract @expression linqApply(@expression a, @expression b);   
}

public sealed class @plus : @operator
{   public override int apply(int a, int b)
    {   return a + b;   }   
    public override @expression linqApply(@expression a, @expression b)
    {   return new @constant {Value = a.extract() + b.extract()};   }   
}

public sealed class @times : @operator
{   public override int apply(int a, int b)
    {   return a * b;   }   
    public override @expression linqApply(@expression a, @expression b)
    {   return new @constant {Value = a.extract() * b.extract()};   }   
}

public sealed class @minus: @operator
{   public override int apply(int a, int b)
    {   return a - b;   }
    public override @expression linqApply(@expression a, @expression b)
    {   return new @constant {Value = a.extract() - b.extract()};   }   
}