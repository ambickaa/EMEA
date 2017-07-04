@isTest
public class AccountTacticalPlanElementControllerTest {
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
    	AccountTacticalPlanElementController controller = new AccountTacticalPlanElementController();
    	controller.italyController = new AccountTacticalPlanItalyController();
        TestAccountListInterface.basicTest( controller.italyController );
    }
}