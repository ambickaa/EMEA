public class TriggerChangeYearOnCountry implements Triggers.Handler{
    public Map<String, String> fieldsNamesForChangePY;
    public Map<String, Object> fieldsNamesForChangeCY;
    public Map<String, String> fieldsNamesPPY;
    public Map<ID,Year__c> years=new Map<ID,Year__c>();
    
    public void handle()
    {
        if (Trigger.isUpdate){
            for(Year__c year:[SELECT ID, YearNextYear__c,YearPreviousYear__c FROM Year__c]){
                years.put(year.ID, year);
            }
            Map<ID,Country__c> oldCountries = (Map<ID,Country__c>)Trigger.oldMap;
            for (Country__c newCountry : (List<Country__c>)Trigger.new) 
            {
                Country__c oldCountry = oldCountries.get(newCountry.Id);
                
    //*******************************************************************************************************
    // AFTER CORN YEAR ON COUNTRY HAS CHANGED:
    //*******************************************************************************************************   
                
                if (newCountry.LKP_CurrentYear__c != oldCountry.LKP_CurrentYear__c)
                {
                    Year__c year = years.get(oldCountry.LKP_CurrentYear__c);
                    
    //*******************************************************************************************************
    // MOVE VALUES FORWARD:
    //*******************************************************************************************************   
                    
                    if (year != null && newCountry.LKP_CurrentYear__c == year.YearNextYear__c)
                    {
                        informMapsNextYear(newCountry); 
                    
                        BatchUpdateAccountsOnChangeYear Batch = new BatchUpdateAccountsOnChangeYear(Util.recordType.get('Account:GroupFarmSite'),newCountry,fieldsNamesForChangePY,fieldsNamesForChangeCY, fieldsNamesPPY,true);
                        BatchUpdateAccountsOnChangeYear distBatch = new BatchUpdateAccountsOnChangeYear(Util.recordType.get('Account:DistRetPoS'),newCountry,fieldsNamesForChangePY,fieldsNamesForChangeCY, fieldsNamesPPY,true);
                        
                        Database.executebatch(Batch,100);
                        Database.executebatch(distBatch,100);
                    }
                    
    //*******************************************************************************************************
    // MOVE VALUES BACKWARDS:
    //*******************************************************************************************************   
    
                    else if (year != null && newCountry.LKP_CurrentYear__c == year.YearPreviousYear__c)
                    {   
                        informMapsPreviousYear(newCountry); 
                    
                        BatchUpdateAccountsOnChangeYear Batch = new BatchUpdateAccountsOnChangeYear(Util.recordType.get('Account:GroupFarmSite'),newCountry,fieldsNamesForChangePY,fieldsNamesForChangeCY, fieldsNamesPPY, false);
                        BatchUpdateAccountsOnChangeYear distBatch = new BatchUpdateAccountsOnChangeYear(Util.recordType.get('Account:DistRetPoS'),newCountry,fieldsNamesForChangePY,fieldsNamesForChangeCY, fieldsNamesPPY,false);
                        
                        Database.executebatch(Batch,100);
                        Database.executebatch(distBatch,100);
                    }
                }           
                
    //*******************************************************************************************************
    // AFTER OSR YEAR ON COUNTRY HAS CHANGED:
    //*******************************************************************************************************   
                
                if (newCountry.LKP_OSRYear__c != oldCountry.LKP_OSRYear__c)
                {
                    Year__c year = years.get(oldCountry.LKP_OSRYear__c);
                    
    //*******************************************************************************************************
    // MOVE VALUES FORWARD:
    //*******************************************************************************************************   
                    
                    if (year != null && newCountry.LKP_OSRYear__c == year.YearNextYear__c)
                    { 
                    
                        informMapsNextOSRYear(newCountry); 
                    
                        BatchUpdateAccountsOnChangeYear Batch = new BatchUpdateAccountsOnChangeYear(Util.recordType.get('Account:GroupFarmSite'),newCountry,fieldsNamesForChangePY,fieldsNamesForChangeCY, fieldsNamesPPY,true);
                        BatchUpdateAccountsOnChangeYear distBatch = new BatchUpdateAccountsOnChangeYear(Util.recordType.get('Account:DistRetPoS'),newCountry,fieldsNamesForChangePY,fieldsNamesForChangeCY, fieldsNamesPPY,true);
                        
                        Database.executebatch(Batch,100);
                        Database.executebatch(distBatch,100);
                    }
                    
    //*******************************************************************************************************
    // MOVE VALUES BACKWARDS:
    //*******************************************************************************************************
    
                    else if (year != null && newCountry.LKP_OSRYear__c == year.YearPreviousYear__c)
                    {
                       
                        informMapsPreviousOSRYear(newCountry); 
                    
                        BatchUpdateAccountsOnChangeYear Batch = new BatchUpdateAccountsOnChangeYear(Util.recordType.get('Account:GroupFarmSite'),newCountry,fieldsNamesForChangePY,fieldsNamesForChangeCY, fieldsNamesPPY, false);
                        BatchUpdateAccountsOnChangeYear distBatch = new BatchUpdateAccountsOnChangeYear(Util.recordType.get('Account:DistRetPoS'),newCountry,fieldsNamesForChangePY,fieldsNamesForChangeCY, fieldsNamesPPY,false);
                        
                        Database.executebatch(Batch,100);
                        Database.executebatch(distBatch,100);
                    }
                }                                                       
            }
        }
    }   
    
    //*******************************************************************************************************
    // FIELDS TO UPDATE AFTER CORN YEAR ON COUNTRY HAS BEEN MOVED FORWARD
    // Map key is the field to be replaced with the value 
    // - account.CHK_Visited_PPY__c=account.Visited_PY__c;
    // - account.Visited_PY__c=account.GC_is_Visited__c;
    // - account.GC_is_Visited__c=false;
    //*******************************************************************************************************   
    
    public void informMapsNextYear(Country__c country){
        
        fieldsNamesForChangePY = new Map<String, String>();
        fieldsNamesForChangeCY= new Map<String, Object>();
        fieldsNamesPPY = new Map<String, String>();        
        
        fieldsNamesForChangeCY.put('GC_is_Visited__c',false);
        fieldsNamesForChangePY.put('Visited_PY__c','GC_is_Visited__c');
        fieldsNamesPPY.put('CHK_Visited_PPY__c','Visited_PY__c');
        
        fieldsNamesForChangeCY.put('CHK_AcreageSownCornCY__c',true);
        fieldsNamesForChangePY.put('CHK_AcreageSownCornPY__c','CHK_AcreageSownCornCY__c');
        fieldsNamesPPY.put('CHK_AcreageSownCornPPY__c','CHK_AcreageSownCornPY__c');
        
        fieldsNamesForChangeCY.put('CHK_AcreageSownOsrCY__c',false);
        fieldsNamesForChangePY.put('CHK_AcreageSownOsrPY__c','CHK_AcreageSownOsrCY__c');
        fieldsNamesPPY.put('CHK_AcreageSownOsrPPY__c','CHK_AcreageSownOsrPY__c');
    
        fieldsNamesForChangeCY.put('FR_POG_CORN_MS_CY__c',Double.valueOf('0.0'));
        fieldsNamesForChangePY.put('FR_POG_CORN_MS_PY__c','FR_POG_CORN_MS_CY__c');
        fieldsNamesPPY.put('NUM_FR_POG_CORN_MS_PPY__c','FR_POG_CORN_MS_PY__c');
        
        fieldsNamesForChangeCY.put('FR_POG_OSR_MS_CY__c',Double.valueOf('0.0'));
        fieldsNamesForChangePY.put('FR_POG_OSR_MS_PY__c','FR_POG_OSR_MS_CY__c');
        fieldsNamesPPY.put('NUM_FR_POG_OSR_MS_PPY__c','FR_POG_OSR_MS_PY__c');
    
        fieldsNamesForChangeCY.put('CP_ACTIMUM_ZV_CY__c',false);
        fieldsNamesForChangePY.put('CP_ACTIMUM_ZV_PY__c','CP_ACTIMUM_ZV_CY__c');
        fieldsNamesPPY.put('CHK_CP_ACTIMUM_ZV_PPY__c','CP_ACTIMUM_ZV_PY__c');
        
        fieldsNamesForChangeCY.put('CP_GUARDIAN_ZV_CY__c',false);
        fieldsNamesForChangePY.put('CP_GUARDIAN_ZV_PY__c','CP_GUARDIAN_ZV_CY__c');
        fieldsNamesPPY.put('CHK_CP_GUARDIAN_ZV_PPY__c','CP_GUARDIAN_ZV_PY__c');
        
        fieldsNamesForChangeCY.put('CP_Harness_ZV_CY__c',false);
        fieldsNamesForChangePY.put('CP_Harness_ZV_PY__c','CP_Harness_ZV_CY__c');
        fieldsNamesPPY.put('CHK_CP_Harness_ZV_PPY__c','CP_Harness_ZV_PY__c');
        
        fieldsNamesForChangeCY.put('DE_Monitor_ZV_CY__c',false);
        fieldsNamesForChangePY.put('DE_Monitor_ZV_PY__c','DE_Monitor_ZV_CY__c');
        fieldsNamesPPY.put('CHK_DE_Monitor_ZV_PPY__c','DE_Monitor_ZV_PY__c');
            
        fieldsNamesForChangeCY.put('DE_Roundoup_ZV_CY__c',false);
        fieldsNamesForChangePY.put('DE_Roundup_ZV_PY__c','DE_Roundoup_ZV_CY__c');
        fieldsNamesPPY.put('CHK_DE_Roundup_ZV_PPY__c','DE_Roundup_ZV_PY__c'); 
    }
    
    //*******************************************************************************************************
    // FIELDS TO UPDATE AFTER CORN YEAR ON COUNTRY HAS BEEN MOVED BACKWARDS
    // Map key is the field to be replaced with the value. 
    // - account.GC_is_Visited__c=account.Visited_PY__c;
    // - account.Visited_PY__c=account.CHK_Visited_PPY__c;
    //This function restores the backup value from PPY to PY and from PY to CY.
    //*******************************************************************************************************

    public void informMapsPreviousYear(Country__c country){
        
        fieldsNamesForChangePY = new Map<String, String>();
        fieldsNamesPPY = new Map<String, String>();
        fieldsNamesForChangeCY= new Map<String, Object>();

        fieldsNamesForChangePY.put('GC_is_Visited__c','Visited_PY__c');
        fieldsNamesPPY.put('Visited_PY__c','CHK_Visited_PPY__c');
        fieldsNamesForChangeCY.put('CHK_Visited_PPY__c',false);
        
        fieldsNamesForChangePY.put('CHK_AcreageSownCornCY__c','CHK_AcreageSownCornPY__c');
        fieldsNamesPPY.put('CHK_AcreageSownCornPY__c','CHK_AcreageSownCornPPY__c');
        fieldsNamesForChangeCY.put('CHK_AcreageSownCornPPY__c',false);
        
        fieldsNamesForChangePY.put('CHK_AcreageSownOsrCY__c','CHK_AcreageSownOsrPY__c');
        fieldsNamesPPY.put('CHK_AcreageSownOsrPY__c','CHK_AcreageSownOsrPPY__c');
        fieldsNamesForChangeCY.put('CHK_AcreageSownOsrPPY__c',false);
        
        if(country.Name == 'France'){
            fieldsNamesForChangePY.put('FR_POG_CORN_MS_CY__c','FR_POG_CORN_MS_PY__c');
            fieldsNamesPPY.put('FR_POG_CORN_MS_PY__c','NUM_FR_POG_CORN_MS_PPY__c');
            fieldsNamesForChangeCY.put('NUM_FR_POG_CORN_MS_PPY__c',0);
            
            fieldsNamesForChangePY.put('FR_POG_OSR_MS_CY__c','FR_POG_OSR_MS_PY__c');
            fieldsNamesPPY.put('FR_POG_OSR_MS_PY__c','NUM_FR_POG_OSR_MS_PPY__c');
            fieldsNamesForChangeCY.put('NUM_FR_POG_OSR_MS_PPY__c',0);
        }     
        
        if(country.Name == 'Ukraine' || country.Name == 'Germany'){
            fieldsNamesForChangePY.put('CP_ACTIMUM_ZV_CY__c','CP_ACTIMUM_ZV_PY__c');
            fieldsNamesPPY.put('CP_ACTIMUM_ZV_PY__c','CHK_CP_ACTIMUM_ZV_PPY__c');
            fieldsNamesForChangeCY.put('CHK_CP_ACTIMUM_ZV_PPY__c',false);
            
            fieldsNamesForChangePY.put('CP_GUARDIAN_ZV_CY__c','CP_GUARDIAN_ZV_PY__c');
            fieldsNamesPPY.put('CP_GUARDIAN_ZV_PY__c','CHK_CP_GUARDIAN_ZV_PPY__c');
            fieldsNamesForChangeCY.put('CHK_CP_GUARDIAN_ZV_PPY__c',false);
            
            fieldsNamesForChangePY.put('CP_Harness_ZV_CY__c','CP_Harness_ZV_PY__c');
            fieldsNamesPPY.put('CP_Harness_ZV_PY__c','CHK_CP_Harness_ZV_PPY__c');
            fieldsNamesForChangeCY.put('CHK_CP_Harness_ZV_PPY__c',false);
            
            fieldsNamesForChangePY.put('DE_Monitor_ZV_CY__c','DE_Monitor_ZV_PY__c');
            fieldsNamesPPY.put('DE_Monitor_ZV_PY__c','CHK_DE_Monitor_ZV_PPY__c');
            fieldsNamesForChangeCY.put('CHK_DE_Monitor_ZV_PPY__c',false);
            
            fieldsNamesForChangePY.put('DE_Roundoup_ZV_CY__c','DE_Roundup_ZV_PY__c');
            fieldsNamesPPY.put('DE_Roundup_ZV_PY__c','CHK_DE_Roundup_ZV_PPY__c');
            fieldsNamesForChangeCY.put('CHK_DE_Roundup_ZV_PPY__c',false);
        }  
    }
    
    //*******************************************************************************************************
    // FIELDS TO UPDATE AFTER OSR YEAR ON COUNTRY HAS BEEN MOVED FORWARD
    // Map key is the field to be replaced with the value 
    // - account.CHK_Visited_OSR_PPY__c=account.CHK_Visited_OSR_PY__c;
    // - account.CHK_Visited_OSR_PY__c=account.CHK_Visited_OSR_CY__c;
    // - account.CHK_Visited_OSR_CY__c=false;
    //*******************************************************************************************************
    
    public void informMapsNextOSRYear(Country__c country){
        
        fieldsNamesForChangePY = new Map<String, String>();
        fieldsNamesForChangeCY= new Map<String, Object>();
        fieldsNamesPPY = new Map<String, String>();
       
        fieldsNamesForChangeCY.put('CHK_Visited_OSR_CY__c',false);
        fieldsNamesForChangePY.put('CHK_Visited_OSR_PY__c','CHK_Visited_OSR_CY__c');
        fieldsNamesPPY.put('CHK_Visited_OSR_PPY__c','CHK_Visited_OSR_PY__c');
    }
    
    //*******************************************************************************************************
    // FIELDS TO UPDATE AFTER OSR YEAR ON COUNTRY HAS BEEN MOVED BACKWARDS
    // Map key is the field to be replaced with the value 
    // - account.CHK_Visited_OSR_CY__c=account.CHK_Visited_OSR_PY__c;
    // - account.CHK_Visited_OSR_PY__c=account.CHK_Visited_OSR_PPY__c;
    //*******************************************************************************************************
    
    public void informMapsPreviousOSRYear(Country__c country){
        
        fieldsNamesForChangePY = new Map<String, String>();
        fieldsNamesPPY = new Map<String, String>();
        fieldsNamesForChangeCY= new Map<String, Object>();
        
        fieldsNamesForChangePY.put('CHK_Visited_OSR_CY__c','CHK_Visited_OSR_PY__c');
        fieldsNamesPPY.put('CHK_Visited_OSR_PY__c','CHK_Visited_OSR_PPY__c');
        fieldsNamesForChangeCY.put('CHK_Visited_OSR_PPY__c',false);   
    }
}