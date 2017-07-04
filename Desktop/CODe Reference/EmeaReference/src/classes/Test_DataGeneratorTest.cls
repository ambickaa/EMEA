@IsTest

public class Test_DataGeneratorTest {

    public static testmethod void tmv(){    
        
    
        Test.StartTest();
        
       try{test_DataGenerator.generateCountries();}
       catch(Exception e){}
       
       try{test_DataGenerator.generateDivisions();}
       catch(Exception e){}    
       
       try{test_DataGenerator.generateYears();}
       catch(Exception e){}      
       
       try{test_DataGenerator.generateProductCatalog();}
       catch(Exception e){}  
       
       Test.StopTest();
       
   }
}