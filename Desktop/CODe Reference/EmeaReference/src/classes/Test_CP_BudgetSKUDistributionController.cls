@isTest
public class Test_CP_BudgetSKUDistributionController
{
    public static Id accountRecordType, recordTypeBudget, productRecordType;
     
    static void init()
    {       
        accountRecordType = Util.recordtype.get('Account:DistRetPoS');
        recordTypeBudget = Util.recordtype.get('Action_Plan_Line__c:CP_Budget');
        productRecordType = Util.recordtype.get('Product2:CPSalesProduct');
    }
    
    public static testMethod void testMyController()
    {
        init();
        
        Integer fiscalYear;
        if (date.today().month()>=9) fiscalYear = System.Date.today().year()+1;
        else fiscalYear = System.Date.today().year();
        String stringFiscalYear = String.valueOf(fiscalYear);
        
        User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
        Country__c country = new Country__c(Name = currentUser.Country, Units_of_Measurement__c = 'Basic Units');
        insert country;
        
        Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType);
        insert vend;
           
        Division__c d = new Division__c(Name = 'Roundup');
        insert d;
        
        Product2 prod = new Product2(Name = 'product1', Family='Roundup', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPriceEntry = new PricebookEntry(Pricebook2Id = pricebookId , Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPriceEntry;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', CP_Account_Type__c = 'Distributor', CountryRef__c = country.Id, Integration_Key__c='PBCUSTOM', isActive=true);
        insert customPB;
        
        PricebookEntry customPriceEntry = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prod.Id, UnitPrice = 15000, IsActive = true);
        insert customPriceEntry;
        
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        apl.TXT_External_ID__c = String.valueOf(prod.Id).substring(0,15) + '-' + stringFiscalYear + '-' + String.valueOf(UserInfo.getUserId()).substring(0,15) + '-' + 'budget';
        apl.LKP_SKU__c = prod.Id;
        apl.NUM_Budget__c = 15000;
        apl.PICK_Budget_Fiscal_Year__c = stringFiscalYear;
        apl.RecordTypeId = recordTypeBudget;
        insert apl;
        
        PageReference pageRef = Page.CP_BudgetDistribution;
        Test.setCurrentPage(pageRef);        
        CP_BudgetSKUDistributionController controller = new CP_BudgetSKUDistributionController();
        controller.getIsDevice();        
        controller.getData();             
        System.assertNotEquals(controller.budgetPreview.size(), null);
        
        controller.budgetPreview[0].budget.NUM_Budget__c = 10000;
        controller.saveBudgetSKU();        
        Action_Plan_Line__c  aplAux = [SELECT ID, TXT_External_ID__c, Name, NUM_Budget__c FROM Action_Plan_Line__c WHERE RecordTypeId =: recordTypeBudget LIMIT 1];
        System.assertEquals(10000, aplAux.NUM_Budget__c);
    }
    
    public static testMethod void testMyController2()
    {
        init();
        
        Integer fiscalYear;
        if (date.today().month()>=9) fiscalYear = System.Date.today().year()+1;
        else fiscalYear = System.Date.today().year();
        String stringFiscalYear = String.valueOf(fiscalYear);
        
        User currentuser = [SELECT Id, Name, Country FROM User where Id=:userinfo.getuserId()];
        Country__c country = new Country__c(Name = currentUser.Country, Units_of_Measurement__c = 'Rels');
        insert country;
        
        Account vend = new Account(Name = 'Monsanto Vendor', CountryRef__c = country.Id, Category__c = 'Distributor', GC_Status_Descr__c = 'Active', recordTypeId = accountRecordType);
        insert vend;
           
        Division__c d = new Division__c(Name = 'Roundup');
        insert d;
        
        Product2 prod = new Product2(Name = 'product1', Family='Roundup', ProductSAPCode__c = 'SAPCode1', DivisionRef__c = d.Id, ProductVendor__c = vend.Id, recordTypeId = productRecordType);
        insert prod;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPriceEntry = new PricebookEntry(Pricebook2Id = pricebookId , Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPriceEntry;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', CP_Account_Type__c = 'Distributor', CountryRef__c = country.Id, Integration_Key__c='PBCUSTOM', isActive=true);
        insert customPB;
        
        PricebookEntry customPriceEntry = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prod.Id, UnitPrice = 15000, IsActive = true);
        insert customPriceEntry;
        
        Action_Plan_Line__c apl = new Action_Plan_Line__c();
        apl.TXT_External_ID__c = String.valueOf(prod.Id).substring(0,15) + '-' + stringFiscalYear + '-' + String.valueOf(UserInfo.getUserId()).substring(0,15) + '-' + 'budget';
        apl.LKP_SKU__c = prod.Id;
        apl.NUM_Budget_Rel__c = 15000;
        apl.PICK_Budget_Fiscal_Year__c = stringFiscalYear;
        apl.RecordTypeId = recordTypeBudget;
        insert apl;
        
        PageReference pageRef = Page.CP_BudgetDistribution;
        Test.setCurrentPage(pageRef);        
        CP_BudgetSKUDistributionController controller = new CP_BudgetSKUDistributionController();
        controller.getIsDevice();        
        controller.getData();             
        System.assertNotEquals(controller.budgetPreview.size(), null);
        
        controller.budgetPreview[0].budget.NUM_Budget_Rel__c = 10000;
        controller.saveBudgetSKU();        
        Action_Plan_Line__c  aplAux = [SELECT ID, TXT_External_ID__c, Name, NUM_Budget_Rel__c FROM Action_Plan_Line__c WHERE RecordTypeId =: recordTypeBudget LIMIT 1];
        System.assertEquals(10000, aplAux.NUM_Budget_Rel__c);
    }
}