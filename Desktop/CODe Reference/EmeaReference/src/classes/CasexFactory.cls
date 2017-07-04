public class CasexFactory implements AccountListObjectFactory
{
    public  List<AccountListObjectWrapper> createObjectWrapperForAccountId( String accountId )
    {
        List<AccountListObjectWrapper>objects = new List<Casex>();
        al.SoqlBuilder query = new al.SoqlBuilder()
        .selectx( new Set<Object> {'id', 'Subject', 'Description', 'status', 'Priority', 'OwnerId', 'Owner.Name', 'CreatedDate', 'LastModifiedDate' } )
        .fromx( 'Case' );
        query.wherex
        (
            new al.AndCondition()
            .add
            (
                new al.FieldCondition( 'AccountId' ).equals( accountId )
            )
        );

        for( Case c : Database.query( query.toSOQL() ) )
        {
            objects.add( new Casex( c ) );
        }

        return objects;
    }
    
    public AccountListObjectWrapper createObjectWrapperForCaseId( String caseId )
    {
        AccountListObjectWrapper result = new Casex();
        al.SoqlBuilder query = new al.SoqlBuilder()
        .selectx( new Set<Object> { 'Id', 'CaseNumber', 'Subject', 'Description', 'Status', 'AccountId', 
                  'Account.Id', 'Account.Name', 'ContactId', 'Contact.Name', 'Origin', 'ClosedDate', 
                  'Priority', 'OwnerId', 'Owner.Name', 'Owner.FirstName', 'Owner.Email', 'GC_Product_SFID__c', 
                  'GC_Product_SFID__r.Name', 'CreatedDate', 'LastModifiedDate' } )
        .fromx( 'Case' );
        query.wherex(new al.AndCondition().add(new al.FieldCondition( 'Id' ).equals( caseId )));
        
        for( Case c : Database.query( query.toSOQL() ) )
        {
            result =  new Casex( c );
        }

        return result;
    }
    
    public  AccountListObjectWrapper createAnEmptyRecord( String accountId )
    {
        return new Casex( accountId );
    }
}