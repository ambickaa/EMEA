@isTest
private class AccountGiveAwaysControllerTest
{

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
        AccountGiveAwaysController controller = new AccountGiveAwaysController();
        TestAccountListInterface.basicTest( new AccountGiveAwaysController() );
        controller.getMerchandiseManagements();
    }
}