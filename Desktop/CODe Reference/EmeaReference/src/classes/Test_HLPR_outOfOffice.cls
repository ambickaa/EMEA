@isTest
public class Test_HLPR_outOfOffice{
   public static testmethod void HLPR_outOfOffice_Test(){
        Profile p = [select id from profile where name='System Administrator'];
         
        Country__c toCountry= new Country__c(Name='HQ', TacticalPlanSetting__c='HQ', DE_EnableAccountSharing__c=true);
        insert toCountry;
        
        // create a user to run the test as
        User u = new User(alias = 'usertest', email='usertest4@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p.Id, country='HQ',
        timezonesidkey='America/Los_Angeles', username='usertest4@noemail.com');
        insert u;
        system.runAs(u){
        
        Account acc=new Account(Name='Test',CountryRef__c=toCountry.ID,GC_Cust_Account_Grp_Descr__c='Sold-to party',GC_is_Marked_For_Del__c=false);
        insert acc;
        Contact con=new Contact(Lastname='Test user',AccountId = acc.id,Email = 'test@gmail.com');
        insert con;
            
        
        /*Case c1=new Case(AccountId=acc.Id,Reason='Invoice',GC_Secondary_Reason_Descr__c='Invoice Copy',
                              Origin='Email-Billing',Status='Closed',Priority='Medium',description = 'Test');
        insert c1;*/
        
        //EmailTemplate templateId = [Select id, from EmailTemplate where name = 'CS_English'];
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = 'name';
        validEmailTemplate.DeveloperName = 'unique_name_addSomethingSpecialHere';
        validEmailTemplate.TemplateType = 'text';
        validEmailTemplate.FolderId = UserInfo.getUserId();
        validEmailTemplate.Subject = 'Your Subject Here';
        
        insert validEmailTemplate;
        
        OOO_Email_Template_Inventory__c OOO = new OOO_Email_Template_Inventory__c();
        OOO.Name = 'Test';
        OOO.Template_Id__c = validEmailTemplate.id;
        OOO.Template_Name__c = 'CS English';
        
        insert OOO;
        
        Out_Of_Office__c outoff=new Out_Of_Office__c();
        outoff.Name='Test';
        outoff.IS_Active__c=True;
        outoff.Start_Date__c=system.today();
        outoff.End_Date__c=system.today().addDays(10);
        outoff.Case_Origin__c='Email-Billing';
        outoff.Email_Templates__c=OOO.id;
        
        insert outoff;
      
        Case c1=new Case(AccountId=acc.Id,ContactId=con.Id,Reason='Invoice',GC_Secondary_Reason_Descr__c='Invoice Copy',
                              Origin='Email-Billing',Status='Open',Priority='Medium',Subject='test',description = 'Test',GC_Sales_Org_Descr__c='SK01',GC_Sales_District_Descr__c='AG-SK',GC_Division_Descr__c='17',GC_Prdt_Group_Descr__c='Corn');

        Test.startTest();
          insert c1;
        Test.stopTest();
        }
    }
}