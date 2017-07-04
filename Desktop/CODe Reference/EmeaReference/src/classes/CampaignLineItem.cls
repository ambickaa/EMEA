public with sharing class CampaignLineItem implements AccountListObjectWrapper, MassSelectContainer
{
    public Boolean frozen {get; set;}
    public boolean checked {get; set;}
    
    public CampaignLineItem__c record {get; set;}
    public CampaignLineItem nextPeriodeElement {get; set;}
    public CampaignLineItem freeOfChargeElement {get;set;}
    public LookupValue lookupValue {get; set;}
    public String key
    {
        get
        {
            if(key == null)
            {
                key = record.ProductRef__c;
            }
            return key;
        }
         set;
    }
    
    public CampaignLineItem ()
    {
        this.record = new CampaignLineItem__c();
        this.lookupValue = new LookupValue();
        this.checked = false;
        this.frozen=false;
    }

    public CampaignLineItem(CampaignLineItem__c tacticalPlanElement)
    {
        this();
        this.record = tacticalPlanElement;
        this.lookupValue = new LookupValue(record.ProductRef__c, record.ProductRef__r.name);
    
    }
    
    public Boolean isNewCLI
    {
        get
        {
            return record.Id == null;
        }
    }
    
    public Double getInventory()
    {
        Double inventoryNumber = 0;
        
        inventoryNumber = this.record.Inventory__c;
        if(this.freeOfChargeElement <> null && this.freeOfChargeElement.record <> null && this.freeOfChargeElement.record.Inventory__c <> null)
        {
            inventoryNumber+= this.freeOfChargeElement.record.Inventory__c;
        }
        return inventoryNumber;
    }

    public List<sObject> getSelectedRecords()
    {
        
        List<sObject>result = new List<sObject>();
        if(this.nextPeriodeElement == null)
        {
            if(this.checked)
            {
                result.add(record);
            }
        }
        else
        {
            if(this.nextPeriodeElement.checked  && this.nextPeriodeElement.record.id <> null)
            {
                result.add(this.nextPeriodeElement.record);
            }
            if(this.nextPeriodeElement.checked  && this.nextPeriodeElement.freeOfChargeElement <> null && this.nextPeriodeElement.freeOfChargeElement.record.id <> null)
            {
                
                result.add(this.nextPeriodeElement.freeOfChargeElement.record);
            }
        }
        
        
        return result;
    }
    
    public void setStatusByQuantityValue()
    {
        this.record.Status__c = null;
        if(this.record.Forecast__c <> null)
        {
            this.record.Status__c = 'Forecast';
        }
        
        if(this.record.Agreed__c <> null)
        {
            
            this.record.Status__c = 'Ordered / Discussed';
        }
        if(this.record.PoG__c <> null)
        {
            
            this.record.Status__c = 'Confirmed';
        }
        
        if(lookupValue <> null && lookupValue.id <> null && lookupValue.id <> '')
        {
            record.ProductRef__c = lookupValue.id;
            
            if(record.id == null && lookupValue.id <> null)
            {
                //lookupValue.text = [SELECT Name, id, ProductTreatment__c From Product2 WHERE ID = :lookupValue.id].name;
            }
        }
    }

    public List<sObject> getFilledRecords()
    {
        // System.assert(false, Json.serialize(this));
        List<sObject>result = new List<sObject>();
        

       if(this.record.OwnerId <> null)
       {
           this.record.OwnerId = this.record.OwnerId;
       }else
       {
           this.record.OwnerId = Util.currentUser.ID;
       }
        if(this.freeOfChargeElement <> null)
        {
            if(this.record.Type__c == null)
            {
                this.record.Type__c = 'Charged';
            }
            this.record.RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales');
            this.freeOfChargeElement.lookupValue.id = this.lookupValue.id;
            this.freeOfChargeElement.record.Type__c = 'Free of charge';
            this.freeOfChargeElement.record.DistributorRef__c = this.record.DistributorRef__c;
            this.freeOfChargeElement.record.PoS__c = this.record.PoS__c;
            this.freeOfChargeElement.record.PlantingDensity__c = this.record.PlantingDensity__c;
        }
        
        if(this.nextPeriodeElement<> null && Util.currentCampaign <> null)
        {
            this.nextPeriodeElement.record.CampaignRef__c = Util.currentCampaign.id;
            if(this.nextPeriodeElement.record.Type__c == null)
            {
                this.nextPeriodeElement.record.Type__c = 'Charged';
            }
            this.nextPeriodeElement.record.RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales');
            this.nextPeriodeElement.setStatusByQuantityValue();
            
            if(this.nextPeriodeElement.record.id <> null || this.nextPeriodeElement.record.Status__c <> null)
            {
                result.add(this.nextPeriodeElement.record);
            }
            
            
            if(this.nextPeriodeElement.freeOfChargeElement <> null)
            {
                this.nextPeriodeElement.freeOfChargeElement.record.RecordTypeId = Util.recordType.get('CampaignLineItem__c:Sales');
                this.nextPeriodeElement.freeOfChargeElement.record.Type__c = 'Free of charge';
                this.nextPeriodeElement.freeOfChargeElement.record.CampaignRef__c = Util.currentCampaign.id;
                this.nextPeriodeElement.freeOfChargeElement.lookupValue.id = this.nextPeriodeElement.lookupValue.id;
                this.nextPeriodeElement.freeOfChargeElement.record.DistributorRef__c = this.nextPeriodeElement.record.DistributorRef__c;
                this.nextPeriodeElement.freeOfChargeElement.record.PoS__c = this.nextPeriodeElement.record.PoS__c;
                this.nextPeriodeElement.freeOfChargeElement.record.PlantingDensity__c = this.nextPeriodeElement.record.PlantingDensity__c;
                
                this.nextPeriodeElement.freeOfChargeElement.setStatusByQuantityValue();
               
                if(this.nextPeriodeElement.freeOfChargeElement.record.id <> null || this.nextPeriodeElement.freeOfChargeElement.record.Status__c <> null)
                {
                    result.add(this.nextPeriodeElement.freeOfChargeElement.record);
                }
            }
        }
        
        if(this.freeOfChargeElement == null)
        {
           

            if(this.record.Status__c == 'Forecast')
            {
                this.record.Forecast__c = this.record.Quantity__c;
            }else if (this.record.Status__c == 'Ordered / Discussed')
            {
                this.record.Agreed__c = this.record.Quantity__c;
            }else if (this.record.Status__c == 'Confirmed')
            {
                this.record.POG__c = this.record.Quantity__c;
            }
            
            
        }
        
        if(this.nextPeriodeElement == null)
        {
            if(lookupValue <> null && lookupValue.id <> null && lookupValue.id != '')
            {
                record.ProductRef__c = lookupValue.id;
            }
            if(record.id <> null || record.Quantity__c <> null || (LookupValue <> null && LookupValue.id <> null && LookupValue.id <> ''))
            {
                result.add(record);
            }
        }

        
        for(sObject c : result)
        {
            c.put('FarmRef__c', Util.currentAccount.id);
        }
        
        return result;
    }
    // deepClone for italian tactical plan
    public CampaignLineItem deepClone()
    {
        CampaignLineItem cloneItem = this.clone();
        cloneItem.record = this.record.clone(false, true);
        
        cloneItem.record.FarmRef__c = this.record.FarmRef__c;
        cloneItem.lookupValue = this.lookupValue.clone();
        cloneItem.record.Agreed__c = null;
        cloneItem.record.Forecast__c = null;
        cloneItem.record.POG__c = null;
        cloneItem.nextPeriodeElement = null;
        cloneItem.freeOfChargeElement = null;
        cloneItem.record.Type__c = null;
        cloneItem.record.CampaignRef__c = null;
        return cloneItem;
    }
    
}