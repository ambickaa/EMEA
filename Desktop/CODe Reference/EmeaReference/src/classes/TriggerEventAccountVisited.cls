//-------------------------------------------------------------------------------
// TRIGGER ON EVENT: BEFORE INSERT & BEFORE UPDATE
// This Apex class is responsible to check the account fields
// "Visited Corn CY" and "Visited OSR CY" of the account related to the Event
//-------------------------------------------------------------------------------
public without sharing class TriggerEventAccountVisited implements Triggers.Handler
{
    //-------------------------------------------------------
    // Getting the map that relates every country with its dates.
    //-------------------------------------------------------
    public Map<String, AccountVisited__c> Map_Dates
    {
        get {
            if(Map_Dates == null) Map_Dates = AccountVisited__c.getall();
            return Map_Dates;
        } protected set;
    }

    //-----------------------------------------------------------------------
    // Getting the set of all possible words related to the "visit" concept.
    //-----------------------------------------------------------------------
    public Set<String> Set_Subjects
    {
        get {
            if(Set_Subjects == null)
            {
                List<String> List_Subjects = Label.Event_Visit_Subject.split('\r\n');

                Set_Subjects = new Set<String>();
                Set_Subjects.addAll(List_Subjects);
            }
            return Set_Subjects;
        } protected set;
    }

    //-------------------------------------------------------
    // Declaring useful variables
    //-------------------------------------------------------
    public List<Account> List_AccountsToUpdate = new List<Account>();
    public Set<Id> Set_AccountsToUpdate = new Set<Id>();
    public Set<Id> Set_Accounts = new Set<Id>();
    public Set<Id> Set_TPP = new Set<Id>();

    //--------------------------------------------------------------------------------------
    // Executing main method, except for South Africa and CP user (by Division)
    //---------------------------------------------------------------------------------------
    public void handle()
    { 
        if(Util.currentUser.Country != 'South Africa' && Util.currentUser.Division == 'S&T')
        {
            //-------------------------------------------------------
            // Loop for incoming events, always checked as Realized.
            //-------------------------------------------------------
            for(Event e : (List<Event>)Trigger.new)
            {
                e.Realized__c = true;

                Set_Accounts.add(e.WhatId);
                Set_TPP.add(e.LKP_TOUCHPOINT_PROG__c);
            }

            //-----------------------------------------------------------------------
            // Building the map of the affected accounts (only Farms or Distributors).
            //-----------------------------------------------------------------------
            Map<Id, Account> Map_Accounts = new Map<Id, Account>([SELECT Id, CountryRef__r.Name,
                CountryRef__r.LKP_CurrentYear__c, CountryRef__r.LKP_CurrentYear__r.Name,
                CountryRef__r.LKP_OSRYear__c, CountryRef__r.LKP_OSRYear__r.Name,
                CountryRef__r.LKP_CurrentYear__r.YearPreviousYear__r.Name,
                CountryRef__r.LKP_OSRYear__r.YearPreviousYear__r.Name,
                GC_is_Visited__c, CHK_Visited_OSR_CY__c
                FROM Account
                WHERE Id IN :Set_Accounts
                AND RecordType.Name IN ('Group/Farm/Site', 'Dist./Ret./PoS')
                AND CountryRef__c != null]);

            //-------------------------------------------------------
            // Building the map of the related Touchpoint Programs.
            //-------------------------------------------------------
            Map<Id, Touchpoint_Program__c> Map_TPP = new Map<Id, Touchpoint_Program__c>([SELECT Id, LKP_CROP__r.Name, LKP_YEAR__c, LKP_YEAR__r.Name
                FROM Touchpoint_Program__c
                WHERE Id IN :Set_TPP
                AND LKP_CROP__c != null
                AND LKP_YEAR__c != null]);

            //---------------------------------------------------------------------------------------
            // START: Loop for all events that should check the visited fields on their parents.
            //---------------------------------------------------------------------------------------
            for(Event e : (List<Event>)Trigger.new)
            {
                if(Map_Accounts.containsKey(e.WhatId) && (Set_Subjects.contains(e.Subject) || (e.Subject.containsIgnoreCase('visit') && !e.Subject.containsIgnoreCase('NPS'))))
                {
                    //-------------------------------------------------------
                    // 1. Related to a TPP
                    //-------------------------------------------------------
                    if(Map_TPP.containsKey(e.LKP_TOUCHPOINT_PROG__c))
                    {
                        //-----------------------------------------------------------------------------------------------
                        // Related to a Corn TPP => Automatically updates the corresponding field on the parent account.
                        //-----------------------------------------------------------------------------------------------
                        if(Map_TPP.get(e.LKP_TOUCHPOINT_PROG__c).LKP_CROP__r.Name == 'Corn'
                          && Map_Accounts.get(e.WhatId).CountryRef__r.LKP_CurrentYear__c != null
                            && Map_TPP.get(e.LKP_TOUCHPOINT_PROG__c).LKP_YEAR__c == Map_Accounts.get(e.WhatId).CountryRef__r.LKP_CurrentYear__c)
                        {
                            if(!Map_Accounts.get(e.WhatId).GC_is_Visited__c)
                            {
                                Map_Accounts.get(e.WhatId).GC_is_Visited__c = true;
                                Set_AccountsToUpdate.add(Map_Accounts.get(e.WhatId).Id);
                            }
                        }
                        //-----------------------------------------------------------------------------------------------
                        // Related to a OSR TPP => Automatically updates the corresponding field on the parent account.
                        //-----------------------------------------------------------------------------------------------
                        if(Map_TPP.get(e.LKP_TOUCHPOINT_PROG__c).LKP_CROP__r.Name == 'OSR'
              && Map_Accounts.get(e.WhatId).CountryRef__r.LKP_OSRYear__c != null
                            && Map_TPP.get(e.LKP_TOUCHPOINT_PROG__c).LKP_YEAR__c == Map_Accounts.get(e.WhatId).CountryRef__r.LKP_OSRYear__c)
                        {
                            if(!Map_Accounts.get(e.WhatId).CHK_Visited_OSR_CY__c)
                            {
                                Map_Accounts.get(e.WhatId).CHK_Visited_OSR_CY__c = true;
                                Set_AccountsToUpdate.add(Map_Accounts.get(e.WhatId).Id);
                            }
                        }
                    }

                    //-----------------------------------------------------------------------
                    // 2. Not related to any TPP => StartDateTime needs to be reviewed and
                    //    compared to the Corn and OSR dates related to the account country.
                    //-----------------------------------------------------------------------
                    if(!Map_TPP.containsKey(e.LKP_TOUCHPOINT_PROG__c) && Map_Dates.containsKey(Map_Accounts.get(e.WhatId).CountryRef__r.Name))
                    {
                        Date eventDate = Date.valueOf(e.StartDateTime);
            String countryName = Map_Accounts.get(e.WhatId).CountryRef__r.Name;
            
                        //-------------------------------------------------------
                        // Corn dates
                        //-------------------------------------------------------
                        if(Map_Dates.get(CountryName).Corn__c != null && Map_Accounts.get(e.WhatId).CountryRef__r.LKP_CurrentYear__c != null)
                        {
                            List<String> countryDates = Map_Dates.get(CountryName).Corn__c.split('[/-]');
                            String CY = Map_Accounts.get(e.WhatId).CountryRef__r.LKP_CurrentYear__r.Name;
                            String PY = countryDates[1] > countryDates[3] ? Map_Accounts.get(e.WhatId).CountryRef__r.LKP_CurrentYear__r.YearPreviousYear__r.Name : CY;

                            Date countryStartDate = date.valueOf(PY + '-' + countryDates[1] + '-' + countryDates[0]);
                            Date countryEndDate = date.valueOf(CY + '-' + countryDates[3] + '-' + countryDates[2]);
                            
                            if(eventDate >= countryStartDate && eventDate <= countryEndDate)
                            {
                                Map_Accounts.get(e.WhatId).GC_is_Visited__c = true;
                                Set_AccountsToUpdate.add(Map_Accounts.get(e.WhatId).Id);
                            }
                        }
                                
                        //-------------------------------------------------------
                        // OSR dates
                        //-------------------------------------------------------
                        if(Map_Dates.get(CountryName).OSR__c != null && Map_Accounts.get(e.WhatId).CountryRef__r.LKP_OSRYear__c != null)
                        {
                            List<String> countryDates = Map_Dates.get(CountryName).OSR__c.split('[/-]');
                            String CY = Map_Accounts.get(e.WhatId).CountryRef__r.LKP_OSRYear__r.Name;
                            String PY = countryDates[1] > countryDates[3] ? Map_Accounts.get(e.WhatId).CountryRef__r.LKP_OSRYear__r.YearPreviousYear__r.Name : CY;

                            Date countryStartDate = date.valueOf(PY + '-' + countryDates[1] + '-' + countryDates[0]);
                            Date countryEndDate = date.valueOf(CY + '-' + countryDates[3] + '-' + countryDates[2]);

                            if(eventDate >= countryStartDate && eventDate <= countryEndDate)
                            {
                                Map_Accounts.get(e.WhatId).CHK_Visited_OSR_CY__c = true;
                                Set_AccountsToUpdate.add(Map_Accounts.get(e.WhatId).Id);
                            }
                        }
                    }
                }               
            }
            //-------------------------------------------------------------------------------
            // END: Loop for all events that should check the visited fields on their parents.
            //-------------------------------------------------------------------------------
                
            //-------------------------------------------------------
            // Updating affected accounts
            //-------------------------------------------------------
            for(Id aId : Set_AccountsToUpdate)
            {
                List_AccountsToUpdate.add(Map_Accounts.get(aId));
            }
            if(List_AccountsToUpdate.size() > 0)
            {
                try {
                    update List_AccountsToUpdate;
                }
                catch(DMLException e)
                {
                    for(Integer i = 0; i < e.getNumDml(); i++)
                    {
                        system.debug(e.getDmlMessage(i));
                    }
                }
            }
        }
    }
}