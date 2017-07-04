public class AccountxModifier
{
    public void save( Accountx aAccountx )
    {
        upsert aAccountx.record;
    }
}