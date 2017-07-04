@IsTest
public class TactialPlanTest{

    public static testmethod void test(){
		TacticalPlan tp = new TacticalPlan();
		TacticalPlan tp2 = new TacticalPlan(new OpportunityLineItem());
		
		try
		{
			tp.addNextYearTacticalPlan(tp2);
			tp.addNextYearTacticalPlan(tp2);
			tp.addNewEmptyFreeOfCharge();
			tp.createNewEmptyTacticalPlanForTheNextYear();
			tp.createNewEmptyFreeOfChargeForTheNextYear();
			tp.createNewEmptyTacticalPlanForTheNextYear();
			List<sObject> sobj = tp.getFilledRecords();
		}
		catch(Exception e)
		{
			
		}
		
		
    }
    
}