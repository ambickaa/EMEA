@isTest
public class Test_REST_DelLogicalEntityTrialEast{
    public static testmethod void DelTest(){
    
        Test_REST_DataFactoryEast.TestData();
        
        Test.startTest();
        
        List<CampaignLineItemGroup__c> ForDelCLG= new List<CampaignLineItemGroup__c>();
        List<CampaignLineItem__c> ForDelCLI= new List<CampaignLineItem__c>();
        
        for(integer i=0;i<Test_REST_DataFactoryEast.RegPerEntity;i++)
        {
           CampaignLineItemGroup__c CLG =new CampaignLineItemGroup__c(AccountRef__c=Test_REST_DataFactoryEast.Farm.id,
                                                         CampaignRef__c=Test_REST_DataFactoryEast.ca.id,Longitude__c='100',
                                                         Comments__c='Test Trial'+String.valueof(i), Status__c='ongoing',
                                                         HarvestedBy__c='TD', Latitude__c='100', Type__c='Demo', 
                                                         RecordTypeId=Util.recordType.get('CampaignLineItemGroup__c:Trial'),
                                                         idDevice__c=160+i);    
           ForDelCLG.add(CLG);
         }
        insert ForDelCLG;
        ForDelCLG.addAll(Test_REST_DataFactoryEast.gList);     
        
        ProductCatalogEntry__c pcetr = new ProductCatalogEntry__c(ProductCatalogRef__c=Test_REST_DataFactoryEast.trcat.id, 
                                                                  NewProduct__c=true, Price__c=500,Ownerid=Util.CurrentUser.id, 
                                                                  productRef__c=Test_REST_DataFactoryEast.pr2.id);
        insert pcetr;
                                                                 
        CampaignLineItem__c CLI =new CampaignLineItem__c( CampaignRef__c=Test_REST_DataFactoryEast.ca.id,
                                                          FarmRef__c=Test_REST_DataFactoryEast.Farm.id ,idDevice__c=245,
                                                          ProductRef__c= Test_REST_DataFactoryEast.pr2.id,Yield__c=100,
                                                          ProductCatalogEntryRef__c=pcetr.id, 
                                                          RecordTypeId = Util.recordType.get('CampaignLineItem__c:Trial'));   
        insert CLI;                     
        ForDelCLI.add(CLI);
        ForDelCli.addAll(Test_REST_DataFactoryEast.tList);  
        
        REST_DelLogicalEntityTrialEast.REST_DelLogicalEntity_Trial params = new REST_DelLogicalEntityTrialEast.REST_DelLogicalEntity_Trial();
        params.Groups=ForDelCLG;
        params.Trials=ForDelCLI;
             
        REST_DelLogicalEntityTrialEast.REST_DelLogicalEntity_Trial returned = REST_DelLogicalEntityTrialEast.getDeletedTrials(params);
        
        System.assertEquals(returned.trials.Size(),21);
        System.assertEquals(returned.groups.Size(),40);
        
       Test.stopTest();
        
     }
     public static testmethod void ExTest(){

          Test_REST_DataFactoryEast.TestData();

          Test.startTest();

          REST_DelLogicalEntityTrialEast.REST_DelLogicalEntity_Trial params = new REST_DelLogicalEntityTrialEast.REST_DelLogicalEntity_Trial();
          params = REST_DelLogicalEntityTrialEast.getExample();
          
          System.Assert(params.groups.Size()==1);
          System.Assert(params.trials.Size()==1);
          
          Test.stopTest();
          
     }
}