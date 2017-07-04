@isTest
private class AccountDivisionSwitcherControllerTest
{
    static
    {
        Testinit.getDivision('Corn');
        Testinit.getDivision('OSR');
        Testinit.getDivision('CP');
        Testinit.getDivision('Latitude');
        Testinit.getDivision('Monitor');
        Testinit.getDivision('Roundup');
        MixedDMLOps.add( Testinit.farmers );
        
        MixedDMLOps.ins();
        TestInit.setYear( 1 );
        Util.urlParameters.put( 'id', TestInit.farmers.get( 0 ).id );
    }
    static testMethod void myUnitTest()
    {
        AccountDivisionSwitcherController controller = new AccountDivisionSwitcherController();
        
        controller.getListDivisions();
        
        controller.DivisionSelected = 'Corn';
        controller.goToDivision();
        
        controller.DivisionSelected = 'CP';
        controller.goToDivision();
        
        controller.DivisionSelected = null;
        controller.goToDivision();
    }
}