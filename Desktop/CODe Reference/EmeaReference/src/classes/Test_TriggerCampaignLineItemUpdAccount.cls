/*
    @description Test on ability added CampaignLineItem to Account record.
    @copyright PARX
*/
@isTest
private class Test_TriggerCampaignLineItemUpdAccount
{
    private static Id testAccountFirstId;
    private static Id testAccountSecondId;
    
    /*
        @description Initialize required records.
    */
    private static void init()
    {
        TestInit.createAccountListController();
        Account anAccount1 = createAccount(null);
        Account anAccount12 = createAccount(anAccount1.Id);
        Account anAccount121 = createAccount(anAccount12.Id);
        Account anAccount122 = createAccount(anAccount12.Id);
        
        testAccountFirstId = anAccount1.Id;
        testAccountSecondId = anAccount12.Id;
        
    
    }
    
    /*
        @description Check changes in Account records after attach CampaignLineItem record.
    */
    private static testMethod void testInsertCampaignLineItem()
    {
        init();
        
        Map<String, Object> aCampaignLineItemFieldsMap = new Map<String, Object>
        {
            'FarmRef__c' => testAccountFirstId,
            'CampaignRef__c' => TestInit.accountWrapper.campaignRecord.Id,
            'RecordTypeId' => Util.recordType.get('CampaignLineItem__c:Sales')
        };
        
        retoure__c toRetoure= new retoure__c(Account__C=testAccountFirstId,EximusRabat__c = 0, Extrarabatt__c = 0, FruekaufMenge__c = 0, FruekaufRabatt__c = 0, Retoure2__c = 0, Retoure1__c = 0, Retoure3__c = 0, TXT_year__c='2013');
        insert toRetoure;
        
        List<String> aFieldsRe = new List<String>
        {
            'FruekaufMenge__c'
        };
        
        al.OrCondition aCondition = new al.OrCondition();
        aCondition.add(new al.FieldCondition('Account__c', testAccountFirstId));
        al.SoqlBuilder aBuilder = new al.SoqlBuilder()
                  .selectx(aFieldsRe)
                  .fromx('Retoure__c').wherex(aCondition);
                  
        
        //SECOND
        retoure__c toRetoure2= new retoure__c(Account__C=testAccountSecondId,EximusRabat__c = 0, Extrarabatt__c = 0, FruekaufMenge__c = 0, FruekaufRabatt__c = 0, Retoure2__c = 0, Retoure1__c = 0, Retoure3__c = 0, TXT_year__c='2013');
        insert toRetoure2;
        
        List<String> aFieldsRe2 = new List<String>
        {
            'FruekaufMenge__c'
        };
        
        al.OrCondition aCondition2 = new al.OrCondition();
        aCondition.add(new al.FieldCondition('Account__c', testAccountSecondId));
        al.SoqlBuilder aBuilder2 = new al.SoqlBuilder()
                  .selectx(aFieldsRe2)
                  .fromx('Retoure__c').wherex(aCondition2);
                  
        
        
        CampaignLineItem__c aCampaignLineItemFirst = 
                (CampaignLineItem__c)SmartFactory.createSObject('CampaignLineItem__c', aCampaignLineItemFieldsMap);
        
        aCampaignLineItemFieldsMap.put('FarmRef__c', testAccountSecondId);
        CampaignLineItem__c aCampaignLineItemSecond = 
                (CampaignLineItem__c)SmartFactory.createSObject('CampaignLineItem__c', aCampaignLineItemFieldsMap);
        
        Test.startTest();
        insert aCampaignLineItemFirst;
        checkUpdateAccounts(testAccountFirstId, true);
        
        insert aCampaignLineItemSecond;
        checkUpdateAccounts(testAccountSecondId, true);
        
        delete aCampaignLineItemFirst;
        checkUpdateAccounts(testAccountFirstId, false);
        Test.stopTest();
    }
    
    /*
        @description Select tree of Account records.
    */
    private static List<Account> getAccountsInTree(Id theAccountId)
    {
        al.OrCondition aCondition = new al.OrCondition();
        aCondition.add(new al.FieldCondition('Id', theAccountId));
        aCondition.add(new al.FieldCondition('ParentId', theAccountId));
        aCondition.add(new al.FieldCondition('Parent.ParentId', theAccountId));
        List<String> aFields = new List<String>
        {
            'IsCreateCampaignLineItem__c', 
            'Parent.IsCreateCampaignLineItem__c', 
            'Parent.Parent.IsCreateCampaignLineItem__c'
        };
        al.SoqlBuilder aBuilder = new al.SoqlBuilder()
                  .selectx(aFields)
                  .fromx('Account').wherex(aCondition);
        
        //return (List<Account>)Database.query(aBuilder.toSOQL());

		List<Account> anAccountMainList = (List<Account>)Database.query(aBuilder.toSOQL());
	    Map<Id, Boolean> anAccountFlagMap = new Map<Id, Boolean>();
	    for (Account anAccount : anAccountMainList)
	    {
	        anAccountFlagMap.put(anAccount.Id, !anAccount.TacticalPlanElements__r.isEmpty());
	    }         
        List<Account> anAccountList = new List<Account>();
        for (Account anAccount : anAccountMainList)
        {            
            if (anAccountFlagMap.get(anAccount.id) == true)
            {
                anAccountList.add(anAccount);
                if (anAccount.ParentId != null)
                {
                    anAccountList.add(anAccount.Parent);
                }
                if (anAccount.Parent.ParentId != null)
                {
                    anAccountList.add(anAccount.Parent.Parent);
                }                   
            }
        } 	    
	    return anAccountList;
    }
    
    /*
        @description Check Account records after update.
    */
    private static void checkUpdateAccounts(Id theAccountId, Boolean theCanCreate)
    {
        for (Account anAccount : getAccountsInTree(theAccountId))
        {
            if (anAccount.Id != theAccountId)
            {
            	if (anAccount.IsCreateCampaignLineItem__c != null)
            	{            	
                	System.assertEquals(theCanCreate, anAccount.IsCreateCampaignLineItem__c, 'This Account id=' + anAccount.Id + 
                          ' hasn\'t available attach CampaignLineItems.');
            	}
            }
            else
            {
                System.assertEquals(false, anAccount.IsCreateCampaignLineItem__c, 'This Account id=' + 
                              anAccount.Id + ' hasn\'t available attach CampaignLineItems.');
                
                if (anAccount.ParentId != null)
                {
                    System.assertEquals(theCanCreate, anAccount.Parent.IsCreateCampaignLineItem__c, 'This Account id=' + 
                              anAccount.ParentId + ' hasn\'t available attach CampaignLineItems.');
                }
                
                if (anAccount.Parent.ParentId != null)
                {
                    System.assertEquals(theCanCreate, anAccount.Parent.Parent.IsCreateCampaignLineItem__c, 'This Account id=' + 
                              anAccount.Parent.ParentId + ' hasn\'t available attach CampaignLineItems.');
                }
            }
        }
    }
    
    /*
        @description Create Account record by ParentId parameter
    */
    private static Account createAccount(Id theParentId)
    {
        Account anAccount = TestInit.createNewFarmer();
        anAccount.IsCreateCampaignLineItem__c = false;
        anAccount.ParentId = theParentId;
        insert anAccount;
        return anAccount;
    }
}