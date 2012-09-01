<Query Kind="Program" />

void Main()
{
    var query = densities().GetEnumerator();
    var reaper = new List<Density>();
    for (var testVar = query.MoveNext();
        testVar;
        testVar = query.MoveNext())
    {
        reaper.Add(query.Current); // this is Mathematica's Sow!
    }
    reaper.Dump();
    
    CanFloatOnWater().Dump("(can_float_on_water X)");
}

IEnumerable<Density> CanFloatOnWater()
{
    var 
    /** /results = 
        from d in densities()
        where Convert.ToDouble(d.Value) < 1.0
        && !(from w in water_solubles()
            select w.Material).Contains(d.Material)
        select d
        ;
    /** /results = 
        from d in (
            from d in densities()
            where Convert.ToDouble(d.Value) < 1.0
            select d)
        where !(from w in water_solubles()
                select w.Material).Contains(d.Material)
        select d
        ;
    /**/
    results = densities()
        .Where(d => Convert.ToDouble(d.Value) < 1.0)
        .Where(d => !water_solubles()
            .Select(w => w.Material)
            .Contains(d.Material))
        ;
    /**/
    return results;
}

public class Density
{
    public string Material;
    public string Value;
    public Density (string material, string value)
    {
        Material = material;
        Value = value;
    }
}
static IEnumerable<Density> densities() {return new [] {

new Density("sea_water", "1.03"),
new Density("milk", "1.03"),
new Density("olive_oil", "0.92"),
new Density("petroleum", "0.80"),
new Density("ethanol", "0.789"),

new Density("almond_wood", "0.99"),
new Density("apricot_wood", "0.89"),
new Density("apple_wood", "0.88"),
new Density("walnut_wood", "0.8"),
new Density("maple", "0.7"),
new Density("poplar", "0.45"),
new Density("balsa", "0.12"),
new Density("iridium", "22.64"),
new Density("lead", "11.34"),
new Density("plutonium", "19.7"),
new Density("copper", "8.94"),
new Density("steel", "7.8"),
new Density("mercury", "13.6"),
new Density("gold", "19.3"),
new Density("diamond", "3.51"),
new Density("glass", "2.5"),
new Density("sugar", "1.6"),
new Density("fat", "0.94"),
};}

public class Solid
{
    public string Material;
    public Solid(string material)
    {
        Material = material;
    }
}

static IEnumerable<Solid> solids() {return new [] {

new Solid("almond_wood"),
new Solid("apricot_wood"),
new Solid("apple_wood"),
new Solid("walnut_wood"),
new Solid("maple"),
new Solid("poplar"),
new Solid("balsa"),
new Solid("iridium"),
new Solid("lead"),
new Solid("plutonium"),
new Solid("copper"),
new Solid("steel"),
new Solid("gold"),
new Solid("diamond"),
new Solid("glass"), /* at least, to the layman. In fact it's a viscous liquid */
new Solid("sugar"),
new Solid("fat"),
};}

public class Liquid
{
    public string Material;
    public Liquid(string material)
    {
        Material = material;
    }
}
static IEnumerable<Liquid> liquids() {return new [] {

new Liquid("sea_water"),
new Liquid("ethanol"),
new Liquid("pure_water"),
new Liquid("olive_oil"),
new Liquid("petroleum"),
new Liquid("milk"),
};}

public class WaterSoluble
{
    public string Material;
    public WaterSoluble(string material)
    {
        Material = material;
    }
}
static IEnumerable<WaterSoluble> water_solubles() {return new [] {

new WaterSoluble("water"),
new WaterSoluble("sea_water"),
new WaterSoluble("sugar"),
new WaterSoluble("ethanol"),
new WaterSoluble("milk"),
};}