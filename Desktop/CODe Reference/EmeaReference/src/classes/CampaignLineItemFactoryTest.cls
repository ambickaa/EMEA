@isTest
public class CampaignLineItemFactoryTest{
    public static testmethod void CLHT(){
        Test_REST_DataFactoryEast.TestData();
        String CID = String.ValueOf(Test_REST_DataFactoryEast.Farm.id);
        CampaignLineItemFactory ALPHA= new CampaignLineItemFactory();
        List<AccountListObjectWrapper> TESTLIST = ALPHA.createObjectWrapperForAccountId(CID );
        AccountListObjectWrapper Emptytest= ALPHA.createAnEmptyRecord( CID );
        System.Assert(EmptyTest==null);
    }
}