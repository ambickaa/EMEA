global with sharing class BatchAutoCreatePricebook implements Database.Batchable<sObject>{   
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Sales_Org_Code__c,Sales_District_Code__c,Divison_Code__c FROM Order WHERE GC_Doc_Creation_Date__c = THIS_FISCAL_YEAR';
        return Database.getQueryLocator(query);
        
    } 

    global void execute(Database.BatchableContext BC,List<Order> orderList)
    {
        map<String, String> totalPriceBooks = new map<String, String>();
        map<String, String> existingPriceBooks = new map<String, String>();
        List<Active_PriceBooks__c> insertPriceBooks = new List<Active_PriceBooks__c>();

        String priceBookName;
        String thisYear;
        String thisYearQuery;

        FiscalYearSettings currentFY = [Select Name, StartDate, EndDate from FiscalYearSettings where StartDate <= TODAY AND EndDate >= TODAY]; 
        thisYear = currentFY.Name;
        thisYearQuery = '%' + thisYear + '%';

        //Map with active PriceBook labels
        for(Active_PriceBooks__c ap : [SELECT Name FROM Active_Pricebooks__c WHERE Name LIKE : thisYearQuery]){
            existingPriceBooks.put(string.valueof(ap.Name),'Active_PriceBook');
        }

        //Search for missing PriceBooks
        for(Order o : orderList){
            if(o.Sales_District_Code__c != null && o.Divison_Code__c != null && o.Sales_Org_Code__c != null){
                priceBookName = string.valueof(o.Sales_District_Code__c) + '#';

                if(o.Divison_Code__c == '15'){
                    priceBookName = priceBookName + 'CP#';
                } else if (o.Divison_Code__c == '17'){
                    priceBookName = priceBookName + 'RC#';
                }

                priceBookName = priceBookName + string.valueof(thisYear) + '#' + string.valueof(o.Sales_Org_Code__c) + '#00';

                if(!existingPriceBooks.containsKey(priceBookName)){
                    totalPriceBooks.put(priceBookName,'PriceBook');
                }
            }
        }

        //Create list of new PriceBooks
        for(String name : totalPriceBooks.keySet()){
            Active_PriceBooks__c ap1 = new Active_PriceBooks__c (Name = name);
            insertPriceBooks.add(ap1);
        }

        //Insertion of new PriceBooks
        if(insertPriceBooks.size() > 0){
            insert insertPriceBooks;
            system.debug('+++Active PB inserted: ' + insertPriceBooks);
        } 

    }

    global void finish(Database.BatchableContext BC)
    {
    }
}