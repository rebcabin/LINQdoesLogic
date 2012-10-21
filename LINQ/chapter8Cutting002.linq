<Query Kind="Program" />

void Main()
{
    var lives_in = new [] {
        new {person = "anca", country = "usa"},
        new {person = "brian", country = "usa"}, 
        new {person = "murray", country = "canada"},
    };
    
    var north_american = new [] {
        ((IEnumerable<dynamic>)lives_in)
            .Where(l => l.country == "usa")
            //.Concat(new [] {new object ((dynamic)(1))})
            //.Concat(new Action(() => {throw new ApplicationException("cut");}))
            ,
    };
}

// Define other methods and classes here
