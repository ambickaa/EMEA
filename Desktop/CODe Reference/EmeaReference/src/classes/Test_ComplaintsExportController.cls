@isTest

public class Test_ComplaintsExportController
{
    /*
        Class to test all the functionality from ComplaintsExportController. 
    */
    
     private static testmethod void ComplaintsExport()
    {       
        Id rtCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Complaint Quality').getRecordTypeId();
        Id rtCampaign = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('NPS').getRecordTypeId();
        
        Country__c countryArea = new Country__c(name='testCountryArea', TXT_Country_ISO_Code__c='TC');
        insert countryArea;
        Country__c country = new Country__c(name='testCountry', Area__c=countryArea.id, TXT_Country_ISO_Code__c='CC');
        insert country;
        
        Division__c div = new Division__c(name='Corn');
        insert div;
        Product_Grouping__c Prodgroup = new Product_Grouping__c(name='Corn');
        insert Prodgroup;
        Year__c year = new Year__c(name='2015');
        insert year;
        
        Account Account1 =  new Account (Name='TestAccount', Category__c='Farm', GC_Status_Descr__c='Active', CountryRef__c=country.id);
        insert Account1;

        Campaign campaign = new Campaign(RecordTypeId = rtCampaign, Name='testCamp', DivisionRef__c=div.Id, CountryRef__c=country.id, YearV2__c=year.id, TXT_Wave__c='2', TXT_Local_segment__c='-',StartDate=date.newInstance(2016, 1, 7), EndDate=date.newInstance(2017, 12, 25));
        insert campaign;
        
        Case cas1 = new Case(RecordTypeId = rtCase, NPS_CAMPAIGN__c=campaign.id, NPS_RESULT_Q1__c=9, LKP_Country__c=country.id, AccountId = Account1.Id, Status = 'Open', NPS_RESULT_Q4__c='yes', NPS_INTERVIEW_START__c=datetime.newInstance(2015, 7, 20), NPS_INTERVIEW_END__c=datetime.newInstance(2015, 8, 4), PCK_Complaints_Export_Status__c='In Progress');
        insert cas1;
        Case cas2 = new Case(RecordTypeId = rtCase, NPS_CAMPAIGN__c=campaign.id, NPS_RESULT_Q1__c=4, LKP_Country__c=country.id, AccountId = Account1.Id, Status = 'Open', NPS_RESULT_Q4__c='yes', NPS_INTERVIEW_START__c=datetime.newInstance(2015, 7, 20), NPS_INTERVIEW_END__c=datetime.newInstance(2015, 8, 4));
        insert cas2; 
        Test.startTest();

        List<Product2> ListProducts = new List<Product2>();
        integer numProd = 4001;
        for (integer i=0;i<numProd;i++){
            Product2 p = new Product2(Name='Product' + i, DivisionRef__c=div.id, ProductGroupRef__c = Prodgroup.id );
            ListProducts.add(p);
        }
        Insert ListProducts;

        List<Complaint_Products__c> ListCompProd = new List<Complaint_Products__c>();
        integer numCompProd = 4001;
        for (integer i=0;i<numCompProd;i++){
            Complaint_Products__c c = new Complaint_Products__c(LKP_CASE__c=cas1.id, LKP_Product_Variety__c=ListProducts[i].id);
            ListCompProd.add(c);
        }
        Insert ListCompProd;

        Test.setCurrentPageReference(new PageReference('Page.ComplaintsExportExcel1'));
        System.currentPageReference().getParameters().put('params', '1');
        ComplaintsExportController cec = new ComplaintsExportController();
        String T = cec.xlsHeader;
        
        Test.setCurrentPageReference(new PageReference('Page.ComplaintsExportExcel2'));
        System.currentPageReference().getParameters().put('params', '2');
        ComplaintsExportController cec2 = new ComplaintsExportController();
        
        Test.setCurrentPageReference(new PageReference('Page.ComplaintsExportPage'));
        ComplaintsExportController cec3 = new ComplaintsExportController();  
        
        Test.stopTest();    
        
    }
}