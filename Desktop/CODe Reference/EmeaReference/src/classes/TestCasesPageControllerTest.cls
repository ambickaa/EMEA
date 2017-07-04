@IsTest
public with sharing class TestCasesPageControllerTest {
    public static testmethod void basicTest(){
        TestCasePageController controller = new TestCasePageController();
        Change_Request__c cr = new Change_Request__c( StartTestDate__c=System.today(), EndTestDate__c=System.today()+2, Assigned_to__c=controller.selectedSupporter,  Description__c='test test test',  Subject__c='test test test');
        System.assert(controller.getIsAdmin());
        List<SelectOption> supp = controller.listSupportPeople;
        Month month =controller.getMonth();
        month.setCases(new List<Change_Request__c>{cr});
        controller.accessSupporter();
        
        List<Month.Week> weeks = controller.getWeeks();
        system.assertEquals(weeks.size(), month.getWeeks().size());
        controller.next();
        controller.prev();
        String nameMonth=month.getMonthName();
        String nameYear=month.getYearName();
        String[] nameDays=month.getWeekdayNames();
        system.assert(month.getfirstDate()<month.getLastDate());
        
        Month.Day day = new Month.Day(System.today(), 1);
        System.assertEquals(day.getDate(),system.today());
        System.assertEquals(day.getDayOfMonth(),system.today().day());
        //System.assertEquals(day.getDayOfMonth2(),'0'+String.valueOf(system.today().day()));
        System.assertEquals(day.getDayOfYear(),system.today().dayOfYear());
        System.assertEquals(day.getDayAgenda(),day.getcasesToday());
        day.getFormatedDate();
        day.getDayNumber();
        day.getCSSName();
        
    }
}