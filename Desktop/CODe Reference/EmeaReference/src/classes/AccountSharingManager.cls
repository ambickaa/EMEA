public abstract without sharing class AccountSharingManager
{
    public static void updateChildrenSharing(Set<ID> paramAccountIDs)
    {
        Map<ID,Account> accounts = new Map<ID,Account>([
            SELECT
                (
                    SELECT
                        ID
                    FROM 
                        Acreages__r
                    WHERE 
                        AcrYearRef__c = :Util.currentYear.ID OR 
                        AcrYearRef__c = :Util.lastYear.ID
                ),
                (
                    SELECT 
                        CampaignRef__r.DivisionRef__r.Name, 
                        OwnerID
                    FROM 
                        TacticalPlanElements__r
                    WHERE 
                        CampaignRef__r.YearV2__c = :Util.currentYear.ID OR 
                        CampaignRef__r.YearV2__c = :Util.lastYear.ID
                ),
                (
                    SELECT
                        CampaignRef__r.DivisionRef__r.Name,
                        OwnerID
                    FROM
                        CampaignLineItemGroups__r
                    WHERE
                        CampaignRef__r.YearV2__c = :Util.currentYear.ID OR
                        CampaignRef__r.YearV2__c = :Util.lastYear.ID
                ),
                (
                    SELECT
                        ID
                    FROM
                        Contacts
                ),
                CountryRef__r.AcreageSharing__c,
                CountryRef__r.TacticalPlanSharing__c
            FROM 
                Account 
            WHERE 
                CountryRef__r.DE_EnableAccountSharing__c = true AND 
                id in :paramAccountIDs ]);
                            
        List<CampaignLineItem__share> cliShare = new List<CampaignLineItem__share>();
        List<ContactShare> conShare = new List<ContactShare>();
        List<Acreage__share> acrShare = new List<Acreage__share>();
        List<CampaignLineItemGroup__share> cligShare = new List<CampaignLineItemGroup__share>();
        Map<ID,User> allUsers = new Map<ID,User>([SELECT StandardDivision__c FROM User]);    
        
        for(AccountShare AccShare : [SELECT UserOrGroupId, AccountID FROM AccountShare WHERE AccountID in :accounts.keySet() AND AccountAccessLevel != 'Read'])
        {
        		
            for(CampaignLineItem__c cli : accounts.get(AccShare.AccountID).TacticalPlanElements__r)
            {            
                if(
                    (
                        (
                            Util.DIVISION_CORN.equalsIgnoreCase(cli.CampaignRef__r.DivisionRef__r.Name) ||
                            Util.DIVISION_OSR.equalsIgnoreCase(cli.CampaignRef__r.DivisionRef__r.Name)
                        ) &&
                        (
                            Util.DIVISION_CORN.equalsIgnoreCase(allUsers.get(cli.ownerID).StandardDivision__c) ||
                            Util.DIVISION_OSR.equalsIgnoreCase(allUsers.get(cli.ownerID).StandardDivision__c)
                        )
                    ) ||
                    (
                        (
                            Util.DIVISION_CP.equalsIgnoreCase(cli.CampaignRef__r.DivisionRef__r.Name) ||
                            Util.DIVISION_LATITUDE.equalsIgnoreCase(cli.CampaignRef__r.DivisionRef__r.Name) ||
                            Util.DIVISION_MONITOR.equalsIgnoreCase(cli.CampaignRef__r.DivisionRef__r.Name) ||
                            Util.DIVISION_ROUNDUP.equalsIgnoreCase(cli.CampaignRef__r.DivisionRef__r.Name)
                        ) &&
                        Util.Division_CP.equalsIgnoreCase(allUsers.get(cli.ownerID).StandardDivision__c)
                    )){
                    if((accounts.get(AccShare.AccountID)).countryRef__r.TacticalPlanSharing__c){
	                    cliShare.add(new CampaignLineItem__share(
	                        parentID = cli.id,
	                        AccessLevel = 'Edit',
	                        UserOrGroupId = AccShare.UserOrGroupId));
                    }else{                   	
	                    cliShare.add(new CampaignLineItem__share(
	                        parentID = cli.id,
	                        AccessLevel = 'Read',
	                        UserOrGroupId = AccShare.UserOrGroupId));
                    }
                }
            }
            for(CampaignLineItemGroup__c clig : accounts.get(AccShare.AccountID).CampaignLineItemGroups__r)
            {
                if(
                    (
                        (
                            Util.DIVISION_CORN.equalsIgnoreCase(clig.CampaignRef__r.DivisionRef__r.Name) ||
                            Util.DIVISION_OSR.equalsIgnoreCase(clig.CampaignRef__r.DivisionRef__r.Name)
                        ) &&
                        (
                            Util.DIVISION_CORN.equalsIgnoreCase(allUsers.get(clig.ownerID).StandardDivision__c) ||
                            Util.DIVISION_OSR.equalsIgnoreCase(allUsers.get(clig.ownerID).StandardDivision__c)
                        )
                    ) ||
                    (
                        (
                            Util.DIVISION_CP.equalsIgnoreCase(clig.CampaignRef__r.DivisionRef__r.Name) ||
                            Util.DIVISION_LATITUDE.equalsIgnoreCase(clig.CampaignRef__r.DivisionRef__r.Name) ||
                            Util.DIVISION_MONITOR.equalsIgnoreCase(clig.CampaignRef__r.DivisionRef__r.Name) ||
                            Util.DIVISION_ROUNDUP.equalsIgnoreCase(clig.CampaignRef__r.DivisionRef__r.Name)
                        ) &&
                        Util.Division_CP.equalsIgnoreCase(allUsers.get(clig.ownerID).StandardDivision__c)
                    )){
                    if((accounts.get(AccShare.AccountID)).countryRef__r.TacticalPlanSharing__c){
	                    cligShare.add(new CampaignLineItemGroup__share(
	                        parentID = clig.id,
	                        AccessLevel = 'Edit',
	                        UserOrGroupId = AccShare.UserOrGroupId));
                    }else{                   	
	                    cligShare.add(new CampaignLineItemGroup__share(
	                        parentID = clig.id,
	                        AccessLevel = 'Read',
	                        UserOrGroupId = AccShare.UserOrGroupId));
                    }	
                }
            }
            for(Acreage__c acr : accounts.get(AccShare.AccountID).Acreages__r)
            {
            	if((accounts.get(AccShare.AccountID)).CountryRef__r.AcreageSharing__c){
	                acrShare.add(new Acreage__share(
	                    parentID = acr.id,
	                    AccessLevel = 'Edit',
	                    UserOrGroupId = AccShare.UserOrGroupID));
            	} else {
	                acrShare.add(new Acreage__share(
	                    parentID = acr.id,
	                    AccessLevel = 'Read',
	                    UserOrGroupId = AccShare.UserOrGroupID));            	
            	}    
            }
            
            for(Contact c : accounts.get(AccShare.AccountID).Contacts)
            {
                conShare.add(new ContactShare(
                    ContactAccessLevel = 'Edit',
                    ContactID = c.ID,
                    UserOrGroupID = AccShare.UserOrGroupID));
            }
        }
        
        if(!cliShare.isEmpty()) database.insert(cliShare,false);
        if(!cligShare.isEmpty()) database.insert(cligShare,false);
        if(!conShare.isEmpty()) database.insert(conShare,false);
        if(!acrShare.isEmpty()) database.insert(acrShare,false);
        
    }    
    
    
    public static void accountShareInsert(List<AccountShare> paramShareToInsert)
    {
        insert paramShareToInsert;
    }
}