@isTest
public class AdditionalDataCaptureHelperTest {
    @testSetup static void setupData(){
        Account oAccount = new Account(Name='Test Account');
        insert oAccount;
        
        Id recordTypeServiceCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Case').getRecordTypeId();
        List<Case> lstCases = new List<Case>();

        Case oCase1 = new Case();
        oCase1.AccountId = oAccount.Id;
        oCase1.GC_Division_Descr__c = '17';
        oCase1.GC_Sales_Org_Descr__c = 'BE01';
        oCase1.GC_Sales_District_Descr__c = 'AG-BE';
        oCase1.Priority = 'Medium';
        oCase1.Origin = 'Email';
        oCase1.Status = 'New';
        oCase1.Reason = 'Delivery/Shipments';
        oCase1.recordtypeid = recordTypeServiceCase;
        oCase1.GC_Secondary_Reason_Descr__c = 'Cancel Delivery';
        oCase1.Description = 'Test';
        oCase1.Subject = 'test';
      //oCase1.GC_Plant_Desc__c = '1501 - Morrinhos-GO';
      //oCase1.GC_Shipping_Point_Descr__c = '1501-MS-MORRINHOS';
        
        Case oCase2 = new Case();
        oCase2.AccountId = oAccount.Id;
        oCase2.GC_Division_Descr__c = '17';
        oCase2.GC_Sales_Org_Descr__c = 'CH02';
        oCase2.GC_Sales_District_Descr__c = 'AG-BA';
        oCase2.Priority = 'Medium';
        oCase2.Origin = 'Email';
        oCase2.status = 'New';
        oCase2.Reason = 'Claims';
        oCase2.Recordtypeid = recordTypeServiceCase;
        oCase2.GC_Secondary_Reason_Descr__c = 'Recall';
        oCase2.Description = 'Test';
        oCase2.Subject = 'test';
      //oCase2.GC_Plant_Desc__c = '1501 - Morrinhos-GO';
      //oCase2.GC_Shipping_Point_Descr__c = '1501-MS-MORRINHOS';
          
        lstCases.add(oCase1);
        lstCases.add(oCase2);
        insert lstCases;
        
        Additional_Data_capture__c oADC = new Additional_Data_capture__c();
      //oADC.GC_Shipping_Point_Descr__c = '1501-MS-MORRINHOS';
        oADC.Case_ADC__c = oCase1.Id;
        insert oADC;
    }
    
    @isTest static void testAdditionalDataCaptureCreation(){
        List<Case> lstCases = [SELECT Id,GC_Additional_Data_Capture_Descr__c FROM Case];
        system.assertEquals(2, lstCases.size());
        
        for(Case oCase : lstCases){
            oCase.GC_Additional_Data_Capture_Descr__c = 'Campaign Fiscal Year: Test'
                                                        +'\nMaterial: Test'    
                                                        +'\nMDM Action: Test'
                                                        +'\nDocuments to Print: Test'
                                                        +'\nDelivery Date: Test'
                                                        +'\nContract Type: Test'
                                                        +'\nBatch Number 1: Test'
                                                        +'\nBIC: Test'
                                                        +'\nContract Type: Test'
                                                        +'\nControl Key: Test'
                                                        +'\nRequested Pick-Up Date: Test'
                                                        +'\nSpecial Instructions/Comments: Test'
                                                        +'\nDocuments to Print: Test';
        }
        
        update lstCases;
        
        List<Additional_Data_capture__c> lstADC = [SELECT Id FROM Additional_Data_capture__c];
        system.assertEquals(2, lstADC.size());
    }
}