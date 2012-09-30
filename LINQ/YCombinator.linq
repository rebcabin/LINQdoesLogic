<Query Kind="Program" />

void Main()
{   Rec<int, int> t0 = f => n => n==0?1:n*f(f)(n-1);
    t0(t0)(6).Dump("Self-applied function");

    Func<Func<int, int>, Func<int, int>> s = k => n => n==0?1:n*k(n-1);
    Rec<int, int> t1 = f => n => s(f(f))(n);
    t1(t1)(6).Dump("Self application closed over the computation");

    // Y0 is Wes Dyer's Y Combinator from http://bit.ly/d52zI1
    Y0(s)(6).Dump("Self application parameterized over the computation");

    // Y1 from http://bit.ly/Q9pEge is a just a rearrangement of Y0.
    //     n => s(f(f))(n)    and    s(n => f(f)(n))
    // produce the same values, always.
    Y1(s)(6).Dump("Another version more similar to the JavaScript version");

    // Both Y's are completely general.  Here is subject code that 
    // produces Fibonacci numbers recursively.
    s = k => n => n<2?1:k(n-1)+k(n-2);
    Y1(s)(20).Dump("Same self-application applied to a different computation");
}
// The following defines the self-application type 
// Rec<A,R> = R<A,R> -> A->R, that is, function from Rec<A,R> to A->R
delegate Func<A,R> Rec<A,R>(Rec<A,R> _);
public static Func<A,R> Y0<A,R>(Func<Func<A,R>, Func<A,R>> s)
{   Rec<A,R> rec = f => n => s(f(f))(n);
    return rec(rec); // (g |-> g@g) applied to f => ...
}
public static Func<A,R> Y1<A,R>(Func<Func<A,R>, Func<A,R>> s)
{   Rec<A,R> rec = f => s(n => f(f)(n));
    return rec(rec); // (g |-> g@g) applied to f => ...
}
