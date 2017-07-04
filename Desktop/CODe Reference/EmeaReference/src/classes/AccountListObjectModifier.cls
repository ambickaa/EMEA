public interface AccountListObjectModifier
{
    // standaed save method saves lists of wrapper objects
    void save( List<AccountListObjectWrapper> objects );

    // deletes selected records in lists
    void deletex( List<AccountListObjectWrapper> objects );
}