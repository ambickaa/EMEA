public with sharing class Consignment implements AccountListObjectWrapper, MassSelectContainer {

    public boolean checked {get; set;}
    public Consignment__c record {get; set;}
    public LookupValue lookupValue {get; set;}
    public String key{
        get{
            if(key == null)
                key = record.GlobalStockRef__c;
            return key;}
         set;
    }
    
    public Consignment (){
        this.record = new Consignment__c();
        this.lookupValue = new LookupValue();
        this.checked = false;
    }

    public Consignment (Consignment__c consignmentRecord){
        this();
        this.record = consignmentRecord;
        this.lookupValue = new LookupValue(record.ProductCatalogEntryRef__r.ProductRef__c, record.ProductCatalogEntryRef__r.ProductRef__r.Name);
    }
    
    public Boolean isNewConsignment{
        get{
            return record.Id == null;
        }
    }
    
    public List<sObject> getSelectedRecords(){
        List<sObject>result = new List<sObject>();
        
        if(this.checked)
            result.add(record);
        return result;
    }
    
    public List<sObject> getFilledRecords(){
        List<sObject>result = new List<sObject>();
        return result;
    }
}