public interface AccountListObjectFactory
{
    // returns a list of objects of the selected accountid
    List<AccountListObjectWrapper> createObjectWrapperForAccountId( String accountId );
    // creates an empty record prefilled with necessary information for an account
    AccountListObjectWrapper createAnEmptyRecord( String accountId );
}