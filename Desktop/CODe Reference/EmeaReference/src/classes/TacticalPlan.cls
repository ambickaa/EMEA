public with sharing class TacticalPlan  implements AccountListObjectWrapper
{

    public OpportunityLineItem record {get; set;}
    //public TacticalPlan lastYearRecord {get; set;}
    public TacticalPlan nextYearTacticalPlan {get; set;}
    public TacticalPlan freeOfCharge {get; set;}
    public String familyName {get; set;}
    public boolean checked {get; set;}
    public lookupValue lookupValue {get; set;}
    public String productname {get{
            if( record == null || record.PricebookEntry.name == null )
            {
                if( nextYearTacticalPlan != null && nextYearTacticalPlan.record != null && nextYearTacticalPlan.record.PricebookEntry.name != null )
                {
                    return nextYearTacticalPlan.record.PricebookEntry.name;
                }

                if( freeOfCharge != null && freeOfCharge.record != null && freeOfCharge.record.PricebookEntry.name != null )
                {
                    return freeOfCharge.record.PricebookEntry.name;
                }

                if( nextYearTacticalPlan != null && nextYearTacticalPlan.freeOfCharge != null && nextYearTacticalPlan.freeOfCharge.record != null && nextYearTacticalPlan.freeOfCharge.record.PricebookEntry.name != null )
                {
                    return nextYearTacticalPlan.freeOfCharge.record.PricebookEntry.name;
                }

                return '';
            }

            else
            {
                return record.PricebookEntry.name;
            }

        } set;
    }


    /*
    ** CONSTRUCTORS **
    */
    public TacticalPlan()
    {
        record = new OpportunityLineItem();
        record.Forecast__c = 0;
        record.Forecast_FOC__c = 0;
        record.Forecast_50__c= 0;
        record.Agreed_FOC__c = 0;
        record.Confirmed_Sales__c = 0;
        record.POG_FOC__c = 0;
        record.Type__c = 'Charged';
        record.Quantity = 1;
        record.TotalPrice = 1;
        lookupValue = new LookupValue();
    }

    public TacticalPlan( OpportunityLineItem record )
    {
        this.record = record;

        if( record.Forecast__c == null ) record.Forecast__c = 0;

        if( record.Forecast_FOC__c == null ) record.Forecast_FOC__c = 0;

        if( record.Confirmed_Sales__c == null ) record.Confirmed_Sales__c = 0;

        if( record.POG_FOC__c == null ) record.POG_FOC__c = 0;

        if( record.TotalPrice == null ) record.TotalPrice = 1;

        lookupValue = new LookupValue( record.PricebookEntryId, record.PricebookEntry.name );
    }

    //check if this is needed or needs to be modified somehow
    public TacticalPlan( Id pricebookentryid )
    {
        this();
        this.record.PricebookEntryId = pricebookentryid;
        lookupValue = new LookupValue( record.PricebookEntryId, record.PricebookEntry.name );
    }

    //check if this is needed
    public TacticalPlan( Id pricebookentryid, String name )
    {
        this();
        this.record.PricebookEntryId = pricebookentryid;
        this.productname = name;
        lookupValue = new LookupValue( record.PricebookEntryId, record.PricebookEntry.name );
    }



    public TacticalPlan( Id opportunityid, Boolean isOp )
    {
        this();
        this.record.Opportunityid = opportunityid;
        lookupValue = new LookupValue( record.PricebookEntryId, record.PricebookEntry.name );
    }


    //check if this is used
    public TacticalPlan( Id pricebookentryid, Id opportunityid )
    {
        this( pricebookentryid );
        this.record.Opportunityid = opportunityid;
        lookupValue = new LookupValue( record.PricebookEntryId, record.PricebookEntry.name );
    }




    /*
    ** MODIFIERS **
    */
    public void addNextYearTacticalPlan( TacticalPlan nextYearTacticalPlan )
    {
        this.nextYearTacticalPlan = nextYearTacticalPlan;
        this.nextYearTacticalPlan.record.Type__c = 'Charged';
    }

    public void addFreeOfCharge( TacticalPlan FreeOfCharge )
    {
        this.FreeOfCharge = FreeOfCharge;
        this.freeOfCharge.record.Type__c = 'Free of charge';
    }

    public void addNewEmptyFreeOfCharge()
    {
        addFreeOfCharge( new TacticalPlan() );
    }

    public void addNewEmptyFreeOfCharge( String pricebookentryid )
    {
        this.addNewEmptyFreeOfCharge();
        this.freeOfCharge.record.pricebookentryid = pricebookentryid;
    }

    public void createNewEmptyTacticalPlanForTheNextYear()
    {
        if( nextYearTacticalPlan == null ) nextYearTacticalPlan = new TacticalPlan();
    }


    public void createNewEmptyFreeOfChargeForTheNextYear()
    {
        if( this.nextYearTacticalPlan.FreeOfCharge == null ) nextYearTacticalPlan.addFreeOfCharge( new TacticalPlan() );
    }

    public void createNewEmptyTacticalPlanForTheNextYear( Id pricebookentryid )
    {
        this.createNewEmptyTacticalPlanForTheNextYear();
        this.nextYearTacticalPlan.record.pricebookentryid = pricebookentryid;
    }

    public void createNewEmptyFreeOfChargeForTheNextYear( Id pricebookentryid )
    {
        this.createNewEmptyFreeOfChargeForTheNextYear();
        this.nextYearTacticalPlan.freeOfCharge.record.pricebookentryid = pricebookentryid;
    }


    public boolean isEmptyRecord()
    {
        if( record.Agreed_FOC__c == 0 && record.Confirmed_Sales__c == 0 && record.Forecast_50__c == 0 && record.Forecast__c == 0 &&
                record.Forecast_FOC__c == 0 && record.POG_FOC__c == 0 )
        {
            return true;
        }

        else
        {
            return false;
        }
    }


    /*
    **ACCESS DATA - GETTERS **
    */



    public List<sObject> getFilledRecords()
    {
        List<sObject>result = new List<sObject>();

        if( this.nextYearTacticalPlan != null && this.nextYearTacticalPlan.record!= null && this.nextYearTacticalPlan.record.PricebookEntryId == null )
        {
            nextYearTacticalPlan.record.PricebookEntryId = lookupValue.id;
        }

        if( this.freeOfCharge != null && this.freeOfCharge.record!= null && this.freeOfCharge.record.PricebookEntryId == null )
        {
            freeOfCharge.record.PricebookEntryId = lookupValue.id;
        }

        if( this.nextYearTacticalPlan != null && this.nextYearTacticalPlan.freeOfCharge != null && this.nextYearTacticalPlan.freeOfCharge.record!= null && this.nextYearTacticalPlan.freeOfCharge.record.PricebookEntryId == null )
        {
            nextYearTacticalPlan.freeOfCharge.record.PricebookEntryId = lookupValue.id;
        }

        if( this.record != null && !this.isEmptyRecord() )
        {
            if( record.PricebookEntryId == null || String.valueOf( record.PricebookEntryId ) == null|| String.valueOf( record.PricebookEntryId ) == '' )
            {
                record.PricebookEntryId = lookupValue.id;
            }

            if( record.PricebookEntryId != null )
                result.add( record );
        }

        if( this.nextYearTacticalPlan != null )
        {
            //System.assert(false, Json.serialize(nextYearTacticalPlan.getFilledRecords()));
            result.addAll( this.nextYearTacticalPlan.getFilledRecords() );
        }

        if( this.freeOfCharge != null )
        {
            result.addAll( this.freeOfCharge.getFilledRecords() );
        }

        //System.assert(false, result);
        System.debug('***FOC result: ' + result);
        return result;
    }

    public List<sObject> getSelectedRecords()
    {
        List<OpportunityLineItem> result = new List<OpportunityLineItem>();

        if( this.checked != null && this.checked )
        {
            if( this.record != null && idNotNull( this.record ) )
            {
                result.add( record );
            }

            if( this.freeOfCharge != null && idNotNull( this.freeOfCharge.record ) )
            {
                result.add( this.freeOfCharge.record );
            }
        }

        if( this.nextYearTacticalPlan != null && this.nextYearTacticalPlan.checked != null && this.nextYearTacticalPlan.checked )
        {
            if( this.nextYearTacticalPlan != null &&  idNotNull( this.nextYearTacticalPlan.record ) )
            {
                result.add( this.nextYearTacticalPlan.record );
            }

            if( this.nextYearTacticalPlan != null && this.nextYearTacticalPlan.freeOfCharge != null && idNotNull( this.nextYearTacticalPlan.freeOfCharge.record ) )
            {
                result.add( this.nextYearTacticalPlan.freeOfCharge.record );
            }
        }

        return result;
    }
    private boolean idNotNull( OpportunityLineItem o )
    {
        if( o!= null && String.valueOf( o.id ) != null && String.valueOf( o.id ) != '' )
        {
            return true;
        }

        else
        {
            return false;
        }
    }
}