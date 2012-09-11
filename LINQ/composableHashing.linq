<Query Kind="Program" />

void Main()
{
    var words = default(IEnumerable<string>);
    using (var f = new StreamReader(@"c:/tmp/words.txt"))
    {
        words = f.ReadToEnd()
            .Split('\n')
            .Select(w => w.Trim())
            ;
    }

    // Don't try this -- it's semantically correct but brutally slow
    /** /
    words
        .ToArray()  // comment out this ToArray to make it even slower
        .RandomChoice(words.Count(), 1000)
        .Where(s => words
            .ToHashSet() // comment out this ToHashSet to make it faster
            .Contains(s))
        .Count()
        .Dump("Number of sample words in the original (expect 1000)");
    /**/
    
    new [] { new {
            aWords = words.ToArray(), 
            hWords = words.ToHashSet()
        }   }
        .Select(o => new {
            hWords = o.hWords,
            sample = o.aWords.RandomChoice(o.aWords.Count(), 1000)
        })
        .Select(o => o.sample
            .Where(s => o.hWords.Contains(s))
        )
        .ElementAt(0)
        .Count()
        .Dump("number of samples in the original set (expect 1000)")
        ;
}


public static class Extensions
{
    private static Random random = new Random();
    public static IEnumerable<T> RandomChoice<T>(this IEnumerable<T> source, int length, int count = 1)
    {
        var result = new T [count];
        for (var i = 0; i < count; i++)
            result[i] = source.ElementAt(random.Next(0, length));
        return result;
    }
    
    public static ICollection<T> AddTo<T>(this ICollection<T> target, T item)
    {
        target.Add(item);
        return target;
    }
    
    public static HashSet<T> ToHashSet<T>(this IEnumerable<T> source)
    {
        return source.Aggregate(
            new HashSet<T>(), 
            (hs, elt) => (HashSet<T>)(hs.AddTo(elt)));
    }
}
