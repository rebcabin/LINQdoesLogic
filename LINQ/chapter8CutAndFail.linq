<Query Kind="Program">
  <Reference>&lt;RuntimeDirectory&gt;\Microsoft.CSharp.dll</Reference>
  <Namespace>Microsoft.CSharp.RuntimeBinder</Namespace>
</Query>

void Main()
{
    var lives_in = new dynamic [] {
        new {person = "anca", country = "usa"},
        new {person = "brian", country = "usa"}, 
        new {person = "murray", country = "canada"},
    };
    
    var north_american_1 = new [] {
        lives_in.Where(l => l.country == "usa"),
        lives_in.Where(l => l.country == "canada"),
    };
    
    var north_american_2 = new [] {
        lives_in.Where(l => l.country == "usa")
                .Fail(),
        lives_in.Where(l => l.country == "canada"),
    };

    var north_american_3 = new [] {
        lives_in.Where(l => l.country == "usa")
                .Cut(),
        lives_in.Where(l => l.country == "canada"),
    };

    north_american_1.evaluate();
    north_american_2.evaluate();
    north_american_3.evaluate();
}

public class CutException : Exception
{   public IEnumerable<dynamic> payload;
}

public static class Extensions
{   /** /
    public static void evaluate(
        this IEnumerable< IEnumerable<dynamic> > alternatives)
    {   alternatives
            .SelectMany(predicates => predicates)
            .Dump()
            ;
    }
    /**/
    public static void evaluate(
        this IEnumerable< IEnumerable<dynamic> > alternatives)
    {   try 
        {   alternatives
                .SelectMany(predicates => predicates.evaluate())
                .Dump()
                ;
        }
        catch (CutException ce) 
        {   ce.payload.Dump();   }
    }
    /**/
    public static IEnumerable<dynamic> evaluate(
        this IEnumerable<dynamic> alternative)
    {   var result = new List<dynamic>();
        foreach (var predicate in alternative)
        {   try { predicate.action(); }
            catch (RuntimeBinderException e) { /*e.Dump();*/ }
            result.Add(predicate);   
        }
        return result;
    }

    public static IEnumerable<dynamic> Fail (this IEnumerable<dynamic> these)
    {   return new dynamic [] {};   }
    
    public static IEnumerable<dynamic> Cut (this IEnumerable<dynamic> these)
    {   return new [] {new {action = new Action(() => 
        { throw new CutException {payload = these.Take(1)}; })
        }};
    }
}

