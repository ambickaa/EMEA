@isTest

public class Test_SMcampaignUpdate {
    
    private static SM_Campaign__c smc;
    private static SM_stage__c st;
    private static VisualRatingProduct__c vrp;
    private static FieldCheckUp__c fcu;
    
    static testmethod void SMupdateTest(){
        
        Country__c pais = new Country__c(name='Spain');
        insert pais;
        Division__c corn = new Division__c(name='corn');
        Year__c y15 = new Year__c(name = '2015');
        insert y15;
        Year__c y16 = new Year__c(name = '2016');
        insert y16;
        y15.YearNextYear__c=y16.Id;
        update y15;
        RecordType rt = [SELECT id, Name from RecordType WHERE Name='Sales Product Catalog' AND SobjectType = 'ProductCatalog__c' limit 1];
        ProductCatalog__c ctlg16 = new ProductCatalog__c(Name='testCatalog2', RecordType=rt, CountryRef__c=pais.Id, DivisionRef__c=corn.Id, YearRef__c=y16.Id);
        insert ctlg16;
        
        smc = new SM_Campaign__c(name = 'testCampaign', LKP_Year__c = y15.Id, LKP_Country__c=pais.Id, LKP_Division__c=corn.Id);
        insert smc;
        st = new SM_stage__c(Name='testStage', LKP_SeedsmanCampaign__c=smc.Id);
        insert st;
        //External Conditions
        SM_External_Conditions__c sec = new SM_External_Conditions__c(LKP_Stage__c=st.Id, LKP_SeedsmanCampaign__c=smc.Id);
        insert sec;
        //Symptom causes
        SM_Symptoms_Causes__c ssc = new SM_Symptoms_Causes__c(LKP_Stage__c=st.Id, LKP_SeedsmanCampaigns__c=smc.Id);
        insert ssc;
        //Visual ratings
        SM_Visual_Rating__c svr = new SM_Visual_Rating__c(LKP_Stage__c=st.Id, LKP_SeedsmanCampaign__c=smc.Id);
        insert svr;  
        //Observations
        SM_Observations__c so = new SM_Observations__c(LKP_Stage__c=st.Id, LKP_SeedsmanCampaign__c=smc.Id);
        insert so;
        
        // TestinG time
        SMcampaignUpdate cu = new SMcampaignUpdate();
        SMcampaignUpdate.cloneCampaign(smc.Id);
        
    }

}