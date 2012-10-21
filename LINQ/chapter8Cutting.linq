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
</Query>

void Main()
{
    // Model all predicates as functions that produce actions. 
    // With and without the "cut."  "Cut" means fail and do not 
    // backtrack.
    /**/
    var matches = new List<Tuple<string, string>>();
    
    var is_prolog_variable = new Func<string, bool>( 
        (string s) => s.Substring(0, 1) ==
            s.Substring(0, 1).ToUpper());
    /**/
    var fail = new Func<Action> (() => new Action(() => 
    {   throw new FailException();   }));

    var cut = new Func<Action> (() => new Action(() => 
    {   throw new CutException();   }));
	
    var lives_in_maker = new Func<string, string, Action>(
        (person, country) => new Action (() => {
            Console.WriteLine ("{{person: \"{0}\", country: \"{1}\"}}",
                person, country);
            return;
        }));
        
    var north_american_maker = new Func<string, Action>(
        (person) => new Action(() => {
            if(is_prolog_variable(person)){
            }
            return;
        }));

    var demo_7 = 
        new [] {
            new [] {
                lives_in_maker("anca", "usa"),
                lives_in_maker("brian", "usa"),
                lives_in_maker("murray", "canada"),
                cut(),
            }};

    var performSequenceWithBacktracking = new Action<
        IEnumerable< Action > > (axs =>
        {   axs
                .Select(ax => {ax(); return 0;})
                .Distinct()
                .Dump()
                ;   });

    var performSequencesWithBacktracking = new Action<
        IEnumerable< IEnumerable< Action > > > (axss =>
        {   axss
                .SelectMany(axs =>
                {   try
                    {   performSequenceWithBacktracking(axs);   }
                    catch (FailException) {
                        if (axss.Last() == axs)
                            Console.WriteLine ("fail");
                    }
                    catch (CutException) {
                        if (axss.Last() == axs)
                            Console.WriteLine ("cut");
                    }
                    return new [] {0};   })
                .Distinct()
                .Dump()
                ;   });

    "".Dump("demo_7");
    performSequencesWithBacktracking(demo_7);
}

class FailException : Exception {}
class CutException : Exception {}