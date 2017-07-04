@IsTest
public class Test_REST_OrderPdfGenerator {
	public static testmethod void pdfGeneratorTes(){
		
		Test.startTest();
		Test_REST_DataFactoryEast.TestData();
		Test.stopTest();
		
		SystemSettings__c s1 = new SystemSettings__c( Name='EAST_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        SystemSettings__c s4 = new SystemSettings__c( Name='EAST_RESET',Value__C='false');
        SystemSettings__c s5 = new SystemSettings__c( Name='EAST_RESET_DATE',Value__C='str');
        
        List<SystemSettings__c> ssList= new List<SystemSettings__c>{s1,s2,s3,s4,s5,s6,s7};
        insert ssList;
		Country__c c= new Country__c(Name='South Africa', TacticalPlanSetting__c='RSA', DE_EnableAccountSharing__c=false);
	    insert c;
        Account a= new Account(CountryRef__c=c.ID, Name='GRANJA 234',BlankVATNumber_RSA__c=true);        
        insert a;
        
        Order__c o=new Order__c(Name='Order Name',RecordTypeId='012D000000037kHIAQ',AccountRef_RSA__c=a.ID,Status_RSA__c='Approved',PdfSent_RSA__c = False,Signed_RSA__c = True, IdDevice__c=1);
        o.id = Database.insert(o).getId();
        system.debug('id de order: '+ Order__c.Id);
                       
        Attachment attach1=new Attachment (OwnerID=Util.currentUser.ID,ParentId=o.id,name='signature.png', body=Blob.valueOf('testing pdf'));
        Attachment attach2=new Attachment (OwnerID=Util.currentUser.ID,ParentId=o.id,name='Signature_tech.png', body=Blob.valueOf('testing pdf'));
        Attachment attach3=new Attachment (OwnerID=Util.currentUser.ID,ParentId=o.id,name='Signature_terms.png', body=Blob.valueOf('testing pdf'));
        Attachment attach4=new Attachment (OwnerID=Util.currentUser.ID,ParentId=o.id,name='Signature_privacy.png', body=Blob.valueOf('testing pdf'));
        Attachment attach5=new Attachment (OwnerID=Util.currentUser.ID,ParentId=o.id,name='Signature_storage.png', body=Blob.valueOf('testing pdf'));
        
        List<Attachment> attachList= new List<Attachment>{attach1,attach2,attach3,attach4, attach5};
        insert attachList; 
        
        List<campaignlineitem__c> CLIList= [SELECT id,name FROM campaignlineitem__c where PlantingDensity__c= '30000'];
        CLIList[0].PreliminaryOrderRef_RSA__c=o.id;
        update CLIList[0];
         
         System.RestContext.request = new RestRequest();
        RestContext.request.requestURI = '/dummy/pdfGenerator_5/';
        RestContext.request.addHeader('email', 'sr13@fullbox.mto');    
        REST_OrderPdfGenerator.generateSignedPdfs();
	}
}