<Query Kind="Program" />

void Main()
{
	composer_periods
		.Where(cp => cp.Composer == "chopin" && cp.Period == "baroque")
		.Dump("Query (composer_period chopin baroque)")
		;

	composer_periods
		.Where(cp => cp.Period == "baroque")
		.Dump("Query (composer_period Who baroque)")
		;

	composer_periods
		.Where(cp => cp.Period == "baroque")
		.Dump("Query (composer_period Who baroque)")
		;
		
	composer_periods
		.Dump("Query (composer_period Who Period)")
		;
		
	
}

// Define other methods and classes here

public class ComposerPeriod
{
	public string Composer;
	public string Period;
	
	public ComposerPeriod(string composer, string period)
	{
		Composer = composer;
		Period = period;
	}
}

static IEnumerable<ComposerPeriod> composer_periods = new [] {
	new ComposerPeriod("chopin", "romantic"),
	new ComposerPeriod("brahms", "romantic"),
	new ComposerPeriod("berlioz", "romantic"),
	new ComposerPeriod("bach", "baroque"),
	new ComposerPeriod("vivaldi", "baroque"),
	new ComposerPeriod("telleman", "baroque"),
	new ComposerPeriod("stravinsky", "contemporary"),
	new ComposerPeriod("messiaen", "contemporary"),
	new ComposerPeriod("ives", "contemporary"),
	new ComposerPeriod("mozart", "classical"),
	new ComposerPeriod("haydn", "classical"),
	new ComposerPeriod("lutoslawski", "contemporary"),
	new ComposerPeriod("beethoven", "classical"),
	new ComposerPeriod("beethoven", "romantic"),/* yes, both !! */
	new ComposerPeriod("tchaikovsky", "romantic"),
};