public with sharing class AccountAcreagesProductListControllerTest {
	static
    {
        MixedDMLOps.add( Testinit.farmers );
        
        MixedDMLOps.ins();
        Testinit.getDivision('Corn');
        TestInit.setYear( 1 );
        Util.urlParameters.put( 'id', TestInit.farmers.get( 0 ).id );
    }

    static testMethod void basicTest()
    {
    	AccountAcreagesProductListController controller = new AccountAcreagesProductListController();
        TestAccountListInterface.basicTest( new AccountAcreagesProductListController() );
        controller.getAcreageList();
    }
}