public class Accountx
{
    public Account record {get; set;}
    public boolean checked {get; set;}

    public Accountx() {}

    public Accountx( Account record )
    {
        this();
        this.record = record;
    }
}