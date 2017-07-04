@IsTest
public class AccountFreeOfChargeControllerTest {
	
  	public static testmethod void test(){
		
		try
		{
			AccountFreeOfChargeController  controller = new AccountFreeOfChargeController ();			
			AccountFreeOfChargeController.FreeOfCharge test = controller.getFreeOfCharge();

			
		}
		catch(Exception e)
		{
			
		}
		
		try
		{
			AccountFreeOfChargeController  controller = new AccountFreeOfChargeController ();	
			controller.doLoadProductPickerRegular();		
			
		}
		catch(Exception e)
		{
			
		}
    }
}