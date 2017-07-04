@isTest
private class AccountAcreageListControllerTest
{
    static
    {
        MixedDMLOps.add( Testinit.farmers );
        MixedDMLOps.ins();
        for(Acreage__c a : Testinit.acreages)
        {
        	a.AcrFarmRef__c = Testinit.farmers.get(0).id;
        }
        
        MixedDMLOps.ins();
        Testinit.getDivision('Corn');
        TestInit.setYear( 1 );
        Util.urlParameters.put( 'id', TestInit.farmers.get( 0 ).id );
    }

    static testMethod void basicTest()
    {
    	insert  Testinit.acreages;
    	AccountAcreageListController controller = new AccountAcreageListController();
        TestAccountListInterface.basicTest( new AccountAcreageListController() );
        controller.getAcreageList();
    }
}