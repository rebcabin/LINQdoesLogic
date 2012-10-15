<Query Kind="Program">
  <Reference>E:\Infer.NET\Bin\Infer.Compiler.dll</Reference>
  <Reference>E:\Infer.NET\Bin\Infer.Runtime.dll</Reference>
  <Reference>&lt;ProgramFilesX86&gt;\Microsoft SDKs\Reactive Extensions\v2.0\Binaries\.NETFramework\v4.0\Microsoft.Reactive.Testing.dll</Reference>
  <Reference>&lt;ProgramFilesX86&gt;\Microsoft SDKs\Reactive Extensions\v2.0\Binaries\.NETFramework\v4.0\System.Reactive.Core.dll</Reference>
  <Reference>&lt;ProgramFilesX86&gt;\Microsoft SDKs\Reactive Extensions\v2.0\Binaries\.NETFramework\v4.0\System.Reactive.Interfaces.dll</Reference>
  <Reference>&lt;ProgramFilesX86&gt;\Microsoft SDKs\Reactive Extensions\v2.0\Binaries\.NETFramework\v4.0\System.Reactive.Linq.dll</Reference>
  <Reference>&lt;ProgramFilesX86&gt;\Microsoft SDKs\Reactive Extensions\v2.0\Binaries\.NETFramework\v4.0\System.Reactive.PlatformServices.dll</Reference>
  <Reference>&lt;ProgramFilesX86&gt;\Microsoft SDKs\Reactive Extensions\v2.0\Binaries\.NETFramework\v4.0\System.Reactive.Providers.dll</Reference>
  <Reference>&lt;ProgramFilesX86&gt;\Microsoft SDKs\Reactive Extensions\v2.0\Binaries\.NETFramework\v4.0\System.Reactive.Runtime.Remoting.dll</Reference>
  <Reference>&lt;ProgramFilesX86&gt;\Microsoft SDKs\Reactive Extensions\v2.0\Binaries\.NETFramework\v4.0\System.Reactive.Windows.Forms.dll</Reference>
  <Reference>&lt;ProgramFilesX86&gt;\Microsoft SDKs\Reactive Extensions\v2.0\Binaries\.NETFramework\v4.0\System.Reactive.Windows.Threading.dll</Reference>
  <Namespace>MicrosoftResearch.Infer.Models</Namespace>
  <Namespace>MicrosoftResearch.Infer</Namespace>
  <Namespace>MicrosoftResearch.Infer.Distributions</Namespace>
</Query>

void Main()
{
#region demo6

    var demo6 = default(IEnumerable< Action > );

    var displayMaker = new Func<string, Action>
        (s => new Action
            (() => Console.WriteLine(s)));
            
    var fail = new Action(() => 
    {   throw new ApplicationException("fail");   });

    demo6 = new Action [] {
        displayMaker("success_goal1"),
        displayMaker("success_goal2"),
        displayMaker("success_goal3"),
        displayMaker("success_goal4"),
        fail,
        displayMaker("success_goal5"),
        displayMaker("success_goal6"),
        displayMaker("success_goal7"),
        };
        
    var performSequence = new Action<
        IEnumerable<Action> > (axs =>
        {   try 
            {   axs
                    .Select(ax => {ax(); return 0;})
                    .Distinct()
                    .Dump()
                    ;
            } catch (Exception exception) 
            {   Console.WriteLine ("fail");   }   });

    "".Dump("demo6");
    performSequence(demo6);
#endregion

#region demo6_1
    var demo6_1 = default(
        IEnumerable< IEnumerable< Action > >);

    demo6_1 = new Action [] [] {
        new Action [] {
            displayMaker("success_goal1"),
            displayMaker("success_goal2"),
            displayMaker("success_goal3"),
            displayMaker("success_goal4"),
            fail,
            displayMaker("success_goal5"),
            displayMaker("success_goal6"),
            displayMaker("success_goal7"),
        },
        new Action [] {
            displayMaker("haha"),
            fail,
            displayMaker("boohoo"),
        },
    };
    
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
                    catch (Exception) {
                        if (axss.Last() == axs)
                            Console.WriteLine ("fail");
                    }
                    return new [] {0};   })
                .Distinct()
                .Dump()
                ;   });

    "".Dump("demo6_1");
    performSequencesWithBacktracking(demo6_1);
#endregion
}
