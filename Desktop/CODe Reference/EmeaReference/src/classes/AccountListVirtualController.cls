public with sharing virtual class AccountListVirtualController implements AccountListInterface
{
    // accountId filled by page parameter
    public String accountId {get; set;}

    // jumper tag to used by pagereference methods
    public String jumperTag {get; set;}

    // spectial mode for contact
    public String mode {get; set;}
    
    public transient User infoUser { get;set;}
    
    public transient Account account{ get;set;}
     
    public Retoure__c Retoure{ get;set;}
    

    // List of wrapper objects
    public List<AccountListObjectWrapper> wrapperObjects
    {
        get
        {
            if ( wrapperObjects == null )
            {
                wrapperObjects = objectFactory.createObjectWrapperForAccountId( accountId );

                if (Util.urlParameters.get('action') == 'newLine' && Util.urlParameters.get('mode') == mode)
                {
                    wrapperObjects.add(objectFactory.createAnEmptyRecord( accountId ));
                }
            }

            return wrapperObjects;
        }
        set;
    }
    
    // field Set Manager
    public FieldSetMemberxManager fieldSetManager {get; set;}

    //Factory and modifier virsual strategy
    protected AccountListObjectFactory objectFactory;
    protected AccountListObjectModifier objectModifier;

    public AccountListVirtualController()
    {
       String year;
        // error avoid
       
        try{
        If(Util.currentCampaign!=null)year=Util.CurrentCampaign.YearV2__r.Name;
        else if(Util.currentCampaign==null)year=Util.currentYear.Name;
        }  catch( Exception e ) {System.debug(e);}
        
        try
        {
        
        
        List<Retoure__c> retoures = [
            SELECT Division__c, EximusRabat__c, Extrarabatt__c, FruekaufMenge__c, FruekaufRabatt__c, Id, Retoure2__c, Retoure1__c, Retoure3__c, RabattMenge__c , NUM_MENGE_TAX__c, Vorlieferant2__r.Name, Vorlieferant1__r.Name, Vorlieferant3__r.Name, Clemente_Rabatt__c, TXT_year__c 
            FROM Retoure__c 
            WHERE Account__c =: Util.currentAccount.Id and Division__c =: Util.currentDivision.Id and TXT_year__c =: year LIMIT 1
         ];  
         if (retoures.size() > 0){
            Retoure = retoures.get(0);
        }
        else{
            
            Retoure = new Retoure__c ( Account__c = Util.currentAccount.ID, Division__c = Util.currentDivision.Id, TXT_Year__c = year);
         }
            // accountId initalized by url parameter
            accountId = Util.urlParameters.get( 'id' );
            // set standard modifier to virtual modifier
            objectModifier = new AccountListVirtualModifier();
            
            // Retoure

         
         
        }

        catch( Exception e ) {System.debug(e);}


    }
    
    public Boolean getIsHasElements()
    {
        return wrapperObjects != null && wrapperObjects.size() > 0;
    }
    

    public boolean getIsEditButton()
    {
        return Util.hasPermissionsForCampaignLineItemEdit;
       
    }
    
    public boolean getIsStandard()
    {
      return Util.isCpStandard;
    }
    
      public boolean getIsCpStandard()
    {
      return Util.isCpStandard;
    }
    
    
    
    //// START TESTING 
    public boolean getIsAccOwn()
    {
      return Util.isAccountOwner;
    }
    
    public String getCurrentDiv()
    {
      return util.currentDivision.Name;
    }
   
 public String getCurrentCamp()
    {
      return util.currentCampaign.Name;
    }
    
    
  //// END TESTING
  
  
  

    // standard cancel pagereference used by buttons in components
    public virtual PageReference cancel()
    {
        // url with anchor
        if( jumperTag!= null ) 
        {
            return URLx.setURL( '/apex/'+urlFixed()+accountId+'&division='+Util.divisionId+'#'+jumperTag );
        }
        else
        {
            return URLx.setURL( '/apex/'+urlFixed()+accountId );
        }
    }
    // standard edit returns standard mode = edit; custom component controller overrides this function
    public virtual PageReference edit()
    {
        if( jumperTag!= null )
        {
            return URLx.setURL( '/apex/'+urlFixed()+accountId+'&mode='+mode+'&division='+Util.divisionId+'#'+jumperTag );
        }

        return URLx.setURL( '/apex/'+urlFixed()+accountId +'&mode='+mode+'&division='+Util.divisionId);
    }
    
    public virtual PageReference editRetoure()
    {
        if( jumperTag!= null )
        {
            return URLx.setURL( '/apex/'+urlFixed()+accountId+'&mode='+mode+'&division='+Util.divisionId+'#'+jumperTag );
        }

        return URLx.setURL( '/apex/'+urlFixed()+accountId +'&mode='+mode+'&division='+Util.divisionId);
    }
    
    
    public virtual PageReference addMultipleLines()
    {
        return URLx.setURL( '/apex/AccountaddMultipleLines?id='+accountId+'&mode='+mode+'&division='+Util.divisionId+'&section='+jumperTag+'&selectionMode=enterValue' );
    }
    
    public virtual PageReference addMultipleLines2()
    {
        return URLx.setURL( '/apex/AddMultProduct2TacticalPlan?id='+accountId+'&mode='+mode+'&division='+Util.divisionId+'&section='+jumperTag+'&selectionMode=enterValue' );
    }
    
    public virtual PageReference doLoadProductPicker()
    {
        return URLx.setURL( '/apex/AccountProductPicker?id=' + accountId + '&division=' + Util.divisionId + '&jumperTag=' + jumperTag + '&mode='+mode );
    }

    // reutrns true if list has more than 0 records
    public virtual boolean getIsList()
    {
        try
        {
            return ( wrapperObjects <> null && wrapperObjects.size() > 0 );
        }

        catch( Exception e )
        {
            return false;
        }
    }
    
    //return the display action plan
   public virtual boolean getIsDisplay()
    {
        
          infoUser =[
                    SELECT Is_Country_Manager__c, Is_Regional_Manager__c, Is_Sales_Rep__c, Is_Promoter__c, Profile.Name, StandardDivision__c
                    FROM User 
                    WHERE ID = :userInfo.getUserID()];
           
           account = [SELECT DE_ID_STATUS__c , RecordType.Name
                    FROM Account 
                    WHERE ID = :accountId ];
                    //&& infoUser.Is_Country_Manager__c == false

        if(Util.DIVISION_CP.equalsIgnoreCase(infoUser.StandardDivision__c) ||
           Util.DIVISION_LATITUDE.equalsIgnoreCase(infoUser.StandardDivision__c) ||
           Util.DIVISION_MONITOR.equalsIgnoreCase(infoUser.StandardDivision__c) ||
           Util.DIVISION_ROUNDUP.equalsIgnoreCase(infoUser.StandardDivision__c) ||
           Util.DIVISION_MONFAST.equalsIgnoreCase(infoUser.StandardDivision__c))
           {
            //CP / Latitude / Monitor / Roundup / MONFAST
               if (account.recordType.name.equalsIgnoreCase('Group/Farm/Site') ) {
                   return true;
               }else if (account.recordType.name == 'Dist./Ret./PoS' && ( infoUser.Is_Country_Manager__c == true) && ((Util.isCpStandard) || (
                         'Großhandels-Niederlassung'.equalsIgnoreCase(account.DE_ID_STATUS__c) ||
                         'Großhandels-Zentrale'.equalsIgnoreCase(account.DE_ID_STATUS__c) || 
                         'Wiederverkäufer Stufe'.equalsIgnoreCase(account.DE_ID_STATUS__c) ||
                         'Wiederverkäufer Ost'.equalsIgnoreCase(account.DE_ID_STATUS__c) ||
                         'Wiederverkäufer West'.equalsIgnoreCase(account.DE_ID_STATUS__c)
                      ))) {
                      return true;
               }
               else if(infoUser.Profile.Name == 'System Administrator' || (account.recordType.name == 'Dist./Ret./PoS' && (                      
                          infoUser.Is_Regional_Manager__c == true ||
                          infoUser.Is_Sales_Rep__c == true ||
                          infoUser.Is_Promoter__c == true
                      )&&(Util.isCpStandard ||
                          'Großhandels-Niederlassung'.equalsIgnoreCase(account.DE_ID_STATUS__c) || 
                          'Wiederverkäufer Stufe'.equalsIgnoreCase(account.DE_ID_STATUS__c) ||
                          'Wiederverkäufer Ost'.equalsIgnoreCase(account.DE_ID_STATUS__c) ||
                          'Wiederverkäufer West'.equalsIgnoreCase(account.DE_ID_STATUS__c)
                      ))){
                   return true;
               }
                //BEGIN German AP new security setup
                //Others/SR/TerritoryManagement
               else if (account.recordType.name == 'Others' && infoUser.Is_Sales_Rep__c == true && getIsOwner()){
                   return true;
               }
                //END German AP new security setup
                //
               else
               {
                   return false;
               } //CP / Latitude / Monitor / Roundup
           }else{ 
           // OSR / Corn
              if (account.recordType.name == 'Group/Farm/Site' ){
                   return true;
               }else if(infoUser.Profile.Name == 'System Administrator' || ( account.recordType.name == 'Dist./Ret./PoS' && ( infoUser.Is_Regional_Manager__c == true) && (Util.isCpStandard ||
                         'Großhandels-Niederlassung'.equalsIgnoreCase(account.DE_ID_STATUS__c) ||
                         'Großhandels-Zentrale'.equalsIgnoreCase(account.DE_ID_STATUS__c) ||
                         'Wiederverkäufer Stufe'.equalsIgnoreCase(account.DE_ID_STATUS__c) ||
                         'Wiederverkäufer Ost'.equalsIgnoreCase(account.DE_ID_STATUS__c) ||
                         'Wiederverkäufer West'.equalsIgnoreCase(account.DE_ID_STATUS__c)
                      ))){
                   return true;
               }else if (account.recordType.name == 'Dist./Ret./PoS' && ( infoUser.Is_Country_Manager__c == true ) && (Util.isCpStandard ||
                         'Großhandels-Niederlassung'.equalsIgnoreCase(account.DE_ID_STATUS__c) ||
                         'Großhandels-Niederlassung'.equalsIgnoreCase(account.DE_ID_STATUS__c) ||
                         'Wiederverkäufer Stufe'.equalsIgnoreCase(account.DE_ID_STATUS__c) ||
                         'Wiederverkäufer Ost'.equalsIgnoreCase(account.DE_ID_STATUS__c) ||
                         'Wiederverkäufer West'.equalsIgnoreCase(account.DE_ID_STATUS__c)
                      )){
                      return true;
               }else if(infoUser.Profile.Name == 'System Administrator' || ( account.recordType.name == 'Dist./Ret./PoS' && (infoUser.Is_Sales_Rep__c == true || infoUser.Is_Promoter__c == true
                        )&&(Util.isCpStandard ||
                          'Wiederverkäufer Stufe'.equalsIgnoreCase(account.DE_ID_STATUS__c) ||
                          'Wiederverkäufer Ost'.equalsIgnoreCase(account.DE_ID_STATUS__c) ||
                          'Wiederverkäufer West'.equalsIgnoreCase(account.DE_ID_STATUS__c)
                      ))){
                   return true;
               }
               //BEGIN German AP new security setup
               //Dist/SR/Großhandels-Niederlassung/TerritoryManagement
               else if (account.recordType.name == 'Dist./Ret./PoS' && infoUser.Is_Sales_Rep__c == true && ('Großhandels-Niederlassung'.equalsIgnoreCase(account.DE_ID_STATUS__c) || Util.isCpStandard)
                        && getIsOwner()){
                    return true;
               }
               //Others/SR or Promoter/TerritoryManagement
               else if (account.recordType.name == 'Others' && (infoUser.Is_Sales_Rep__c == true || infoUser.Is_Promoter__c == true) && getIsOwner()){
                    return true;
                }
               //END German AP new security setup
               //Dist./Ret./PoS with ID Status != 'Großhandels-Niederlassung', 'Großhandels-Zentrale', 'Wiederverkäufer Stufe', 'Wiederverkäufer Ost', 'Wiederverkäufer West'
               else{
                   return false;
               }       
           } // OSR / Corn
        
        
    }
    
    public virtual boolean getIsAPRegionalManager () //All conditions included before.
    {
        infoUser =[
                SELECT Is_Regional_Manager__c, Is_Sales_Rep__c, Is_Promoter__c ,  Profile.Name, StandardDivision__c
                FROM User 
                WHERE ID = :userInfo.getUserID()];
       
        account = [SELECT DE_ID_STATUS__c , RecordType.Name
                FROM Account 
                WHERE ID = :accountId ];
        
        if(infoUser.Is_Regional_Manager__c == true &&  account.recordType.name == 'Dist./Ret./PoS' &&(Util.isCpStandard ||
                         'Großhandels-Niederlassung'.equalsIgnoreCase(account.DE_ID_STATUS__c) ||
                         'Großhandels-Zentrale'.equalsIgnoreCase(account.DE_ID_STATUS__c)))
        {
            return true;
        }else if (infoUser.Is_Sales_Rep__c == true && account.recordType.name == 'Dist./Ret./PoS' &&(Util.isCpStandard ||
                          'Wiederverkäufer Stufe'.equalsIgnoreCase(account.DE_ID_STATUS__c) ||
                          'Wiederverkäufer Ost'.equalsIgnoreCase(account.DE_ID_STATUS__c) ||
                          'Wiederverkäufer West'.equalsIgnoreCase(account.DE_ID_STATUS__c)

                      ))
        {
            return true;
        }else if(infoUser.Is_Promoter__c == true && account.recordType.name == 'Dist./Ret./PoS' &&(Util.isCpStandard ||
                          'Wiederverkäufer Stufe'.equalsIgnoreCase(account.DE_ID_STATUS__c) ||
                          'Wiederverkäufer Ost'.equalsIgnoreCase(account.DE_ID_STATUS__c) ||
                          'Wiederverkäufer West'.equalsIgnoreCase(account.DE_ID_STATUS__c)

                      )) 
        {
            return true;
        
        
        }
        else if (account.recordType.name == 'Group/Farm/Site')
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    public virtual boolean getIsOwner()
    {
        
          infoUser =[
                    SELECT Is_Country_Manager__c, Is_Regional_Manager__c, Is_Sales_Rep__c, Profile.Name, StandardDivision__c, Alias
                    FROM User 
                    WHERE ID = :userInfo.getUserID()];
           
           account = [SELECT DE_ID_STATUS__c , RecordType.Name, DE_Owners__c
                    FROM Account 
                    WHERE ID = :accountId ];
        
        if(account.DE_Owners__c != null && account.DE_Owners__c.contains(infoUser.Alias))
        {
            return true;
        }else
        {
            return false;
        }
    }

    // creates new empty record using the specific factory
    public virtual PageReference newRecord()
    {
         system.debug('QUE HA PASADO Aqui?');
        save();
       
        return URLx.setURL( '/apex/'+urlFixed()+accountId+'&action=newLine&mode='+mode+'&division='+Util.divisionId+'#'+jumperTag );
         
    }

    // standard save method uses the standard modifier and returns a new url
   public virtual PageReference saveRetoure()
    {
        try
        {
            
            //Util.addInfoMessage(retoure);
            if(Util.currentAccount.CountryRef__c != null && mode == 'retoureEdit')
            {   
                if (Util.countryView.isGermanActionPlan && Retoure != null)
                {
                    
                    /* START ORIOL 21/12/2015 */
                    //Before Save or Insert check that the MENGE can not be greater than the POG of the Excel Products.
                    Decimal OSR_DECmenge=0;
                    Decimal Corn_DECmenge=0;
                    Boolean BOOcheckError=false;
                    
                    if(util.currentDivision.name == 'OSR'){
                    
                        for(CampaignLineItem__c ForAP : [SELECT POG__c FROM CampaignLineItem__c
                                                       WHERE (CampaignRef__r.isActive=true) 
                                                       AND (CampaignRef__r.Owner.ID=:userInfo.getUserID()) 
                                                       AND (FarmRef__r.ID=:AccountID) 
                                                       AND (Type__c='Charged') 
                                                       AND (ProductCatalogEntryRef__r.DE_isPremium__c =true) 
                                                       AND (ProductRef__r.ProductTreatment__c='Thiram' OR ProductRef__r.ProductTreatment__c='Thiram+DMM') 
                                                       AND (CampaignRef__r.DivisionRef__c=:Util.divisionId)]){
                                                           if(ForAP.POG__c <> null) OSR_DECmenge = OSR_DECmenge + ForAP.POG__c;
                                                           
                                                       }                        
                        
                        //If the MENGE is greater than POG then display the error:
                                        
                        if(Retoure.FruekaufMenge__c > OSR_DECmenge){system.debug('*****4'); Util.addErrorMessage('Die Frühkauf-Menge kann nicht größer sein als: '+OSR_DECmenge); BOOcheckError = true;}
                        if(Retoure.RabattMenge__c > OSR_DECmenge){system.debug('*****5');Util.addErrorMessage('Die Extrarabatt-Menge kann nicht größer sein als: '+OSR_DECmenge); BOOcheckError = true;}
                    }
                    
                    if(util.currentDivision.name == 'Corn'){
                    
                        for(CampaignLineItem__c ForAP : [SELECT POG__c FROM CampaignLineItem__c
                                                       WHERE (CampaignRef__r.isActive=true) 
                                                       AND (CampaignRef__r.Owner.ID=:userInfo.getUserID()) 
                                                       AND (FarmRef__r.ID=:AccountID) 
                                                       AND (Type__c='Charged') 
                                                       //AND (ProductCatalogEntryRef__r.DE_isPremium__c =true)
                                                       AND (ProductCatalogEntryRef__r.CHK_ZVD__c =true)
                                                       //AND (ProductRef__r.ProductTreatment__c='Thiram' OR ProductRef__r.ProductTreatment__c='Thiram+DMM') 
                                                       AND (CampaignRef__r.DivisionRef__c=:Util.divisionId)]){
                                                           if(ForAP.POG__c <> null) Corn_DECmenge = Corn_DECmenge + ForAP.POG__c;
                                                           
                                                       }

                        //If the MENGE is greater than POG then display the error:
                                        
                        if(Retoure.FruekaufMenge__c > Corn_DECmenge){system.debug('*****6'); Util.addErrorMessage('Die Frühkauf-Menge kann nicht größer sein als: '+Corn_DECmenge); BOOcheckError = true;}
                        if(Retoure.RabattMenge__c > Corn_DECmenge){system.debug('*****7');Util.addErrorMessage('Die Extrarabatt-Menge kann nicht größer sein als: '+Corn_DECmenge); BOOcheckError = true;}
                    }   
                    
                    /* END ORIOL 21/12/2015 */                  
                    
                    if(BOOcheckError){
                        return null;
                    }else{
                        if(Retoure.Id == null) insert  Retoure;
                        else                   update Retoure;
                    }
                }
            }
            
            
        } catch (DMLException theException)
        {
            return null;
        }

        if( jumperTag!= null )
        {
            return URLx.setURL( '/apex/'+urlFixed()+accountId+'&division='+Util.divisionId+'#'+jumperTag );
        }
        return URLx.setURL( '/apex/'+urlFixed()+accountId+'&division='+Util.divisionId );
    }
    public virtual PageReference save()
    {
        try
        {
           objectModifier.save( wrapperObjects );
            
            
        } catch (DMLException theException)
        {
            return null;
        }

        if( jumperTag!= null )
        {
            return URLx.setURL( '/apex/'+urlFixed()+accountId+'&division='+Util.divisionId+'#'+jumperTag );
        }
        return URLx.setURL( '/apex/'+urlFixed()+accountId+'&division='+Util.divisionId );
    }

     public virtual PageReference saveTrial()
    {
        try
        {
            //Util.addInfoMessage(retoure);
            if(Util.currentAccount.CountryRef__c != null && mode == 'tacticalEdit')
            {
                if (Util.countryView.isGermanActionPlan && Retoure != null)
                {
                    if(Retoure.Id == null)
                    {
                        insert  Retoure;
                    }else
                    {
                        update Retoure;
                    }
                }
            }
            
           List<AccountListObjectWrapper> wrapperObjectsTemp = new List<AccountListObjectWrapper>();
           
           for(CampaignLineItemGroup aow: (List<CampaignLineItemGroup>)wrapperObjects)
            {
                if(aow.record.OwnerId==Util.currentUser.Id || aow.record.OwnerId==null)
                {
                    wrapperObjectsTemp.add((AccountListObjectWrapper)aow);
                }
            }

            objectModifier.save( wrapperObjectsTemp );
        } catch (DMLException theException)
        {
            return null;
        }

        if( jumperTag!= null )
        {
            return URLx.setURL( '/apex/'+urlFixed()+accountId+'&division='+Util.divisionId+'#'+jumperTag );
        }
        return URLx.setURL( '/apex/'+urlFixed()+accountId+'&division='+Util.divisionId );
    }

    // standard save uses the standard method provided by the specific or standard modifier and returns new urls
    public virtual PageReference deletex()
    {
        
        try{
            objectModifier.deletex( wrapperObjects );

            if( jumperTag!= null )
            {
                return URLx.setURL( '/apex/'+urlFixed()+accountId+'&division='+Util.divisionId+'#'+jumperTag );
            }

            return URLx.setURL( '/apex/'+urlFixed()+accountId+'&division='+Util.divisionId );
        }catch(DMLException e) {
            return null;
        }
    }
    public String urlFixed()
    {
        String urlToRedirect='';
         boolean isCPdiv=False;
        if(util.currentDivision.name!=null && util.currentDivision.name!='')
        {
            for(String div : new List<String> {'CP','Roundup','Latitude','Monitor','Monfast','Guardian Tetra','Harness','Actimum'})
            {
                if(util.currentDivision.name==div && Util.countryView.isGermanActionPlan)isCPdiv=True;
            }
        }
        if(isCPdiv)urlToRedirect= 'AccountViewCPDE?id=';
        
        else urlToRedirect=Util.countryView.country.AccountViewPage__c+'?id=';
        
        return urlToRedirect;
    }
}