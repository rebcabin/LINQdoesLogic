<Query Kind="Program" />

void Main()
{
    var words = default(IEnumerable<string>);
    Console.WriteLine ("The data file for this example is in the DATA sub-directory");
    Console.WriteLine ("of the LINQdoesLogic directory. The name of the file is");
    Console.WriteLine ("WORDS.TXT. You should copy (or move) the file someplace");
    Console.WriteLine ("convenient for you and modify this LINQ script to point");
    Console.WriteLine ("to the actual location of the file on your machine.");
    using (var f = new StreamReader(@"c:/tmp/words.txt"))
    {
        words = f.ReadToEnd()
            .Split('\n')
            .Select(w => w.Trim())
            ;
        words
            .Count()
            .Dump("Count of words in the original file")
            ;
    }
    var sw = new Stopwatch();

    Console.WriteLine ("Test for presence and absence of certain words.");
    sw.Start();
    words
        .Contains("prehistorically")
        .Dump("Does the words IEnumerable contain \"prehistorically\"?")
        ;
    sw.Stop(); sw.ElapsedMilliseconds.Dump("Elapsed milliseconds required to decide whether the words IEnumerable contains \"prehistorically\"");

    sw.Reset(); sw.Start();
    words
        .Contains("zzzzzzzz")
        .Dump("Does the words IEnumerable contain \"zzzzzzzz\"?")
        ;
    sw.Stop(); sw.ElapsedMilliseconds.Dump("Elapsed milliseconds required to decide whether the words IEnumerable contains \"zzzzzzzz\"");
    
    Console.WriteLine ("Create a hash set for more efficient testing.");
    Console.WriteLine ("One way is to iterate over the original IEnumerable with a boolean transform");
    Console.WriteLine ("that inserts the element by side effect and counts the number of unique words");
    sw.Reset(); sw.Start();
    var wordsHashSet = new HashSet<string>();
    words
        // automatically skips duplicate words -- turns out that the
        // famous MOBY word list "single.txt" actually contains a 
        // duplicate -- "animate", which threw off the count by 1.
        // That mistake has certainly been in the data set for years.
        // The following technique, taking advantage of HashSet's
        // "Add" method, as opposed to ICollection's "Add" method,
        // sidesteps the error. To find the duplicate, simply negate
        // the condition in the "Where" call below.
        .Where(w => wordsHashSet.Add(w))
        .Count()
        .Dump("Count of unique words in the hash set")
        ;
    sw.Stop(); sw.ElapsedMilliseconds.Dump("Elapsed milliseconds to build and enumerate the hash set by transformation");

    sw.Reset(); sw.Start();
    wordsHashSet
        .Contains("prehistorically")
        .Dump("Does the hash set contain \"prehistorically\"?")
        ;
    sw.Stop(); sw.ElapsedMilliseconds.Dump("Elapsed milliseconds to decide whether the hash set contains \"prehistorically\"");

    sw.Reset(); sw.Start();
    wordsHashSet
        .Contains("zzzzzzzz")
        .Dump("Does the hash set contain \"zzzzzzzz\"?")
        ;
    sw.Stop(); sw.ElapsedMilliseconds.Dump("Elapsed milliseconds to decide whether the hash set contains \"zzzzzzzz\"");

    Console.WriteLine ("Another way is to Fold (or Aggregate) a streaming insertion operator that");
    Console.WriteLine ("takes an ICollection and an item and returns an ICollection; this is a bit");
    Console.WriteLine ("slower than the transformation method but it is a composable one-liner, since");
    Console.WriteLine ("the result is the collection itself, which can be passed down to later transforms");
    Console.WriteLine ("or dynamically composed in reconfigurable pipeline architectures");
    wordsHashSet = new HashSet<string>();
    sw.Reset(); sw.Start();
    words
        .Aggregate(wordsHashSet, (hs, s) => (HashSet<string>)hs.AddTo(s))
        .Count()
        .Dump("Count of words in the hash set")
        ;
    sw.Stop(); sw.ElapsedMilliseconds.Dump("Elapsed milliseconds to build and enumerate the hash set by aggregation");
    
    var wordsHashSetAsIEnumerable = default(IEnumerable<string>);
    wordsHashSetAsIEnumerable = wordsHashSet;

    Console.WriteLine("If we remove any chance of collusion at the type-system level ");
    Console.WriteLine("between wordsHashSet and the .Contains operator, we see that ");
    Console.WriteLine(".Contains is still smart enough to use the .Contains that's ");
    Console.WriteLine("native to the hash set (technically, it's because the hash set");
    Console.WriteLine("implements ICollection<T>, which implements the efficient ");
    Console.WriteLine("version of .Contains)");
    sw.Reset(); sw.Start();
    wordsHashSetAsIEnumerable
        .Contains("prehistorically")
        .Dump("Does the hash set (as IEnumerable) contain \"prehistorically\"?")
        ;
    sw.Stop(); sw.ElapsedMilliseconds.Dump("Elapsed milliseconds to decide whether the hash set (as IEnumerable) contains \"prehistorically\"");

    Console.WriteLine("We can use the convenience operator .AsEnumerable to obscure ");
    Console.WriteLine("the underlying type of the HashSet and test that IEnumerable's");
    Console.WriteLine(".Contains is smart enough to find the hash-set's .Contains.");
    sw.Reset(); sw.Start();
    wordsHashSet
        .AsEnumerable()
        .Contains("zzzzzzzz")
        .Dump("Does the hash set (as IEnumerable) contain \"zzzzzzzz\"?")
        ;
    sw.Stop(); sw.ElapsedMilliseconds.Dump("Elapsed milliseconds to decide whether the hash set (as IEnumerable) contains \"zzzzzzzz\"");
    
    Console.WriteLine ("The time difference becomes critical when we need to decide ");
    Console.WriteLine ("for a large number of examples, say 1000 randomly chosen words.");
    
    sw.Reset(); sw.Start();
    var sample = words.RandomChoice(words.Count(), 1000);
    sw.Stop(); sw.ElapsedMilliseconds.Dump("Elapsed milliseconds to create a sample of 1000 words");
    
    sw.Reset(); sw.Start();
    sample
        .Where(s => words.Contains(s))
        .Count()
        .Dump("Number of samples present in the source (expect 1000)")
        ;
    sw.Stop(); sw.ElapsedMilliseconds.Dump("Elapsed milliseconds to test 1000 samples without a hash set");
    
    sw.Reset(); sw.Start();
    sample
        .Where(s => wordsHashSet.Contains(s))
        .Count()
        .Dump("Number of samples present in the source (expect 1000)")
        ;
    sw.Stop(); sw.ElapsedMilliseconds.Dump("Elapsed milliseconds to test 1000 samples WITH the hash set");
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
}