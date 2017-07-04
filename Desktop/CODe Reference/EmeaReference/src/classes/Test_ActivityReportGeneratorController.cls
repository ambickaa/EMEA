@Istest
public with sharing class Test_ActivityReportGeneratorController {
    
    private static testMethod void ActivityReportGeneratorController()
    {

        Year__c lastYear = new Year__c (Name='2014', Current_Year__c=false, YearEndDate__c=date.newinstance(1914, 12, 31), 
                                     YearStartDate__c=date.newinstance(1913, 1, 1), CurrentYear_RSA__c=false); 
        insert lastYear;    
        Year__c year= new Year__c (Name='2015', Current_Year__c=true, YearEndDate__c=date.newinstance(2915, 12, 31), 
                                   YearStartDate__c=date.newinstance(1915, 1, 1), CurrentYear_RSA__c=true,
                                   YearPreviousYear__c=lastYear.id); 
        insert year;
        
        Country__c c= new Country__c(Name='Spain');
        insert c;
        
        Account acc = new Account (Name='AccounTest', CountryRef__c=c.Id);
        insert acc;
        
        Acreage__c acr = new Acreage__c (AcrFarmRef__c=acc.Id);
        insert acr;
        
        Field__c fld = new Field__c (Name='FieldTest', LKP_Acreage__c=acr.Id);
        insert fld;
        
        Contact con = new Contact (LastName='ContactTest', Status__c='Active');
        insert con;
        
        Division__c Divi= new Division__c(Name='Corn',Standard__c=true);
        insert Divi;
        
        Product2 p = new Product2(name='testproduct');
        insert p;
        
        ProductCatalog__c pb = new ProductCatalog__c (Name='testpricebook');
        insert pb;
        
        SM_Campaign__c SMCamp = new SM_Campaign__c(CHK_Save_report_library__c=true, Name='SMCampTest', LKP_Catalog__c=pb.Id, LKP_Country__c=c.Id, LKP_Division__c=Divi.Id, LKP_Year__c=year.Id, MPCK_Language__c='en_US');
        insert SMCamp;
        
        FieldCheckUp__c fcu = new FieldCheckUp__c (LKP_Account__c=acc.Id, LKP_Contact__c=con.Id, LKP_Division__c=Divi.Id, LKP_Field__c=fld.Id, LKP_SeedsmanCampaign__c=SMCamp.Id);
        insert fcu;
        
        Note Note = new Note (body='testBody', title='testNote', parentId=fcu.Id);
        insert Note;
                
        //STAGE
        StageMaster__c StageM = new StageMaster__c(Name='StageMTest');
        insert StageM;
        
        SM_stage__c Stage = new SM_stage__c(Name='StageTest', LKP_StageMaster__c=StageM.Id, LKP_SeedsmanCampaign__c=SMCamp.Id);
        insert Stage;
        
        //EXTERNAL CONDITIONS
        ExternalConditionsMaster__c ExtCondMast = new ExternalConditionsMaster__c(Name='ECMTest');
        insert ExtCondMast;
        
        ExternalConditionsLanguage__c ExtCondLang = new ExternalConditionsLanguage__c(Name='ECLTest', LKP_ExternalConditionsMaster__c=ExtCondMast.Id, LKP_Country__c=c.Id);
        insert ExtCondLang;
        
        SM_External_Conditions__c ExtCond = new SM_External_Conditions__c(LKP_Stage__c=Stage.Id, LKP_SeedsmanCampaign__c=SMCamp.Id, LKP_ExternalConditionsMaster__c=ExtCondMast.Id);
        insert ExtCond;
        
        FCU_External_Conditions__c ec = new FCU_External_Conditions__c(LKP_ExternalConditions__c=ExtCond.Id, LKP_FCU__c=fcu.Id, idDevice__c='10');
        insert ec;
        
        Attachment att = new Attachment (Name='testAttachment', body=Blob.valueof('body'), parentId=ExtCondMast.Id);
        insert att;
        //OBSERVATIONS
        SM_Observations__c Obser = new SM_Observations__c(LKP_SeedsmanCampaign__c=SMCamp.Id, LKP_Stage__c=Stage.Id);
        insert Obser;
        
        FCU_Observations__c obs = new FCU_Observations__c (LKP_Observations__c=Obser.Id, LKP_FCU__c=fcu.Id, TXTA_value__c='10');
        insert obs;
                
        //SYMPTOMS & CAUSES
        SymptomsMaster__c SympM = new SymptomsMaster__c(Name='SympMTest');
        insert SympM;
         
        SymptomsCausesMaster__c SympCausM = new SymptomsCausesMaster__c(Name='SympCausMTest', LKP_SymptonsMaster__c=SympM.Id);
        insert SympCausM; 
        
        SM_Symptoms_Causes__c SympCaus = new SM_Symptoms_Causes__c (LKP_SymptomsMaster__c=SympM.Id, LKP_CausesMaster__c=SympCausM.Id, LKP_SeedsmanCampaigns__c=SMCamp.Id, LKP_Stage__c=Stage.Id);
        insert SympCaus;
        
        SymptomsLanguage__c SympL = new SymptomsLanguage__c(Name='SympLTest', LKP_Country__c=c.Id, LKP_SymptomsMaster__c=SympM.Id);
        insert SympL;
        
        FCU_Symptoms_Causes__c sc = new FCU_Symptoms_Causes__c (LKP_SymptomsCauses__c=SympCaus.Id, LKP_FCU__c=fcu.Id, TXTA_Remark__c='test remark');
        insert sc;
        
        //VISUAL RATING
        SM_Visual_Rating__c VisRat = new SM_Visual_Rating__c(LKP_SeedsmanCampaign__c=SMCamp.Id, LKP_Stage__c=Stage.Id);
        insert VisRat;
        
        VisualRatingProduct__c vrp = new VisualRatingProduct__c (FieldCheckUp__c=fcu.Id, LKP_Product__c=p.Id, Name='test vr product');      
        insert vrp;
        
        FCU_Visual_Rating__c vr = new FCU_Visual_Rating__c (LKP_VisualRatingProduct__c=vrp.Id, LKP_VisualRating__c=VisRat.Id, LKP_FCU__c=fcu.Id, TXT_Value__c='20');  
        insert vr;
        
        FCU_Report_Generator__c fcurg = new FCU_Report_Generator__c (LKP_Field_Check_Up__c=fcu.Id, TXT_Notes__c=Note.Id, TXT_Observations__c=obs.Id, TXT_Symptoms_Causes__c=sc.Id, TXT_Visual_rating__c=vr.Id);
        insert fcurg;
        
        ContentVersion doc = new ContentVersion(Title='docTest', PathOnClient = 'xyz', VersionData=Blob.valueOf('testBody'));
        insert doc;
        doc = [SELECT ContentDocumentId FROM ContentVersion WHERE id = :doc.id];
        
        ContentWorkspace lib = [SELECT id, name FROM ContentWorkspace LIMIT 1];   
        SMCamp.PICK_Library__c=lib.name;
        update SMCamp;
        if (lib!=null)
        {
            ContentWorkspaceDoc docLink = new ContentWorkspaceDoc(ContentDocumentId=doc.ContentDocumentId, ContentWorkspaceId=lib.id);
            insert docLink;
        }
        
        User u = new User(id=UserInfo.getUserId(), countryISOCode__c = 'RSA');
        update u;
        
        REST_FCUReportGenerator.sendFCUGenerators();
        
        PageReference pageRef = Page.Seedsman_Report;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('idReport', fcurg.id);
        
        ActivityReportGeneratorController  controller = new ActivityReportGeneratorController();
    }
    
}