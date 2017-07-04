@isTest
public class GenericHistoryControllerTest {
      public static testMethod void myTestGenericHistoryComponentController() {
            
        test_REST_DataFactoryEast.testdata();
        Test.StartTest();
        
        GenericHistoryComponentController controller = new GenericHistoryComponentController();
        
        try{List<GenericHistoryComponentController.objectHistoryLine> ohl=controller.getObjectHistory();}
        catch(Exception e){}
        
        try{String str1=GenericHistoryComponentController.returnFieldLabel('name123');}
        catch(Exception e){}
        
        
        test.StopTest();

      }
}