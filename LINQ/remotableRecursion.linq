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
    
    // LINQ method introduces one level of IEnumerable / IObservable
    var exprs = new [] { // IEnumerable<@expression>
        new @binary {Left  = new @constant {Value = 4},
                     Op    = new @times(),
                     Right = new @binary {Left  = new @constant {Value = 5},
                                          Op    = new @plus(),
                                          Right = new @constant {Value = 6}}}};
    /**/                                      
    Func<int> @throw = () => {
        throw new InvalidOperationException(); 
        return default(int);};
    /**/
    Func<@expression,int>
        @extract = ex =>
            (ex is @constant) ? 
            (ex as @constant).Value 
            : @throw()
            ;
    /**/
    Func<@operator,@expression,@expression,@expression> 
        @apply = (op,a,b) =>
            (op is @plus) ? new @constant {Value = @extract(a) + @extract(b)}
            : (op is @times) ? new @constant {Value = @extract(a) * @extract(b)}
            : (op is @minus) ? new @constant {Value = @extract(a) - @extract(b)}
            : default(@expression)
            ;
    /**/
    Func<Func<@expression,@expression>,Func<@expression,@expression>>
        @eval = ev => ex => 
            (ex is @constant) ? ex 
            : (ex is @binary) ?
            @apply(
                (ex as @binary).Op,
                ev((ex as @binary).Left), 
                ev((ex as @binary).Right))
            : default(@expression)
            ;

    exprs
        .Select(e => Y(@eval)(e))
        .Dump("Good LINQ method: expect IEnum of @expression")
        ;

    // Now we can have some fun and generate a random expression
    Extensions
        .generate()
        .Return()
        .Dump("Random Expression Tree")
        .Select(e => Y(@eval)(e))
        .Dump("Value of the Tree")
        ;

    // or a whole array of random expressions
    Enumerable
        .Range(0, 10)
        .Select(_ => Extensions.generate())
        .Select(e => Y(@eval)(e))
        .Dump("Values of 10 random expression trees")
        ;

    // Reactive version
    Observable
        .Interval(TimeSpan.FromSeconds(0.25))
        .Take(10)
        .Select(_ => Extensions.generate())
        .Subscribe(e => new {expression = e, value = Y(@eval)(e)}
            .Dump("A new expression every tick")
            );
}
delegate Func<A,R> Rec<A,R>(Rec<A,R> _);
public static Func<A,R> Y<A,R>(Func<Func<A,R>, Func<A,R>> s)
{   Rec<A,R> rec = f => n => s(f(f))(n);
    return rec(rec); // (g |-> g@g) applied to f => ...
}
public static class Extensions
{   public static IEnumerable<T> Return<T> (this T input)
    {   return new [] {input};   }
    private static Random random = new Random();
    private static double[] probabilities = 
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
}
public abstract class @expression {}
public sealed class @constant : @expression
{   public int Value {get; set;}
}
public sealed class @binary : @expression
{   public @expression Left  {get; set;}
    public @operator   Op    {get; set;}
    public @expression Right {get; set;}
}
public abstract class @operator {}
public sealed class @plus : @operator {}
public sealed class @times : @operator {}
public sealed class @minus: @operator {}