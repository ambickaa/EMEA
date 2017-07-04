@isTest
private class Test_TriggerPartnerIDtoAccount
{
    static testMethod void empty()
    {
    	TriggerPartnerIDtoAccount t = new TriggerPartnerIDtoAccount();
    }
/*
    @isTest static void test(){
    /* ---------------- Test Data creation ----------------
        RecordType rt=[Select id,Name FROM RecordType WHERE SobjectType='Account' and Name='Dist./Ret./PoS' limit 1];  
        RecordType opprt=[Select id,Name from RecordType where SobjectType='Opportunity' limit 1];
        Country__C c=new Country__C(name='TestCountry');
        insert c;
        Account acc=new Account(RecordType=rt,GC_SAP_ID__c='7654321',GC_Cust_Account_Grp_Descr__c='Sold-to party',Name='Account',Category__c='Distributor',GC_Status_Descr__c='Active',CountryRef__c=c.id, CornTotalAcreagesCY__c=40, OSRTotalAcreagesCY__c=10,CornDekalbMarketShareCY__c=10,totalAcreagesCY__c=50);
        insert acc;
        Sales_Area__c area=new Sales_Area__c(name='ES01/00/15');
        insert area;    
        Partner_Function__c areaMng = new Partner_Function__c(Partner_Function_Descr__c='YB/Area Manager',Relation_Type_Descr__c='Sold-to Party',name='testShipTo1',Primry_Acct_Integration_Key__c=acc.Id,Partner_SAP_ID__c='3456789', Country_Name__c='Andorra');            
        areaMng.Sales_Area_Integration_Key__c=area.id;
        insert areaMng;
    /*----Data for Italy case----
        Country__C ci=new Country__C(name='Italy');
        insert ci;
        Account accShip=new Account(RecordType=rt,GC_SAP_ID__c='7654324',GC_Cust_Account_Grp_Descr__c='Ship-to Party',Name='Account',Category__c='Distributor',GC_Status_Descr__c='Active',CountryRef__c=ci.id, CornTotalAcreagesCY__c=40, OSRTotalAcreagesCY__c=10,CornDekalbMarketShareCY__c=10,totalAcreagesCY__c=50);
        insert accShip;
        
        Sales_Area__c areaIt = new Sales_Area__c(name='IT01/00/15');
        insert areaIt; 
        Account accSold=new Account(RecordType=rt,GC_SAP_ID__c='7654421',GC_Cust_Account_Grp_Descr__c='Sold-to Party',Name='Account',Category__c='Distributor',GC_Status_Descr__c='Active',CountryRef__c=ci.id, CornTotalAcreagesCY__c=40, OSRTotalAcreagesCY__c=10,CornDekalbMarketShareCY__c=10,totalAcreagesCY__c=50);
        insert accSold; 
        
        Partner_Function__c shipTo = new Partner_Function__c(Partner_Function_Descr__c='WE/Ship-to Party',Relation_Type_Descr__c='Ship-to Party',name='testShipToIt',Primry_Acct_Integration_Key__c=accSold.Id,Partner_SAP_ID__c='0007654324', Country_Name__c='Italy');            
        shipTo.Sales_Area_Integration_Key__c=areaIt.id;
        insert shipTo;
        
        Partner_Function__c partIt = new Partner_Function__c(Partner_Function_Descr__c='YA/Sales Representative',Relation_Type_Descr__c='Ship-to Party',name='testAMIt', Primry_Acct_Integration_Key__c=accShip.Id,Partner_SAP_ID__c='0003456789', Country_Name__c='Italy');            
        partIt.Sales_Area_Integration_Key__c=areaIt.id;
                Partner_Function__c partIt2 = new Partner_Function__c(Partner_Function_Descr__c='YA/Sales Representative',Relation_Type_Descr__c='Ship-to Party',name='testAMIt2', Primry_Acct_Integration_Key__c=accShip.Id,Partner_SAP_ID__c='0003456789', Country_Name__c='Italy');            
        partIt2.Sales_Area_Integration_Key__c=areaIt.id;
       list<partner_function__c> partners=new list<partner_function__c>();
        partners.add(partIt);
        partners.add(partIt2);
        insert PARTNERS;
        SYSTEM.debug(PARTNERS);
    /*-------- End data creation --------
        
        
        
    
    }
    */
}