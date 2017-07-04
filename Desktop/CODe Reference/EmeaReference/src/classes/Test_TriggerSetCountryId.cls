/*
    Check equlas two fields from other objects.
*/
@isTest
private class Test_TriggerSetCountryId
{
    private static Map<String, List<sObject>> testObjectsMap;
    private static Map<String, List<Map<String, Object>>> apiNameToValueFieldMap;
    
    static
    {
        //Map APIName object to list of records.
        testObjectsMap = new Map<String, List<sObject>>
        {
            'Country__c' => new List<sObject>
            {
                new Country__c()
            },
            'ProductCatalog__c' => new List<sObject>
            {
                new ProductCatalog__c()
            }
        };
        
        //Map APIName object to List of Maps with APIName to values fields.
        apiNameToValueFieldMap = new Map<String, List<Map<String, Object>>>
        {
            'Country__c' => new List<Map<String, Object>>
            {
                new Map<String, Object>()
            },
            'ProductCatalog__c' => new List<Map<String, Object>>
            {
                new Map<String, Object>()
            }
        };
        
        //fill list of records for test.
        for (String anApiName : apiNameToValueFieldMap.KeySet())
        {
            for (Map<String, Object> anNameToValue : apiNameToValueFieldMap.get(anApiName))
            {
                generatorObjects(anApiName, anNameToValue);
            }
        }
    }
    
    //Check two fields on equals on Country object.
    private static testmethod void testCountry()
    {
        Test.startTest();
        insert testObjectsMap.get('Country__c');
        update testObjectsMap.get('Country__c');
        Set<Id> anObjectIds = Util.getIdSet(testObjectsMap.get('Country__c'));
        for (Country__c aCountry : selectCoutryByIds(anObjectIds).values())
        {
            System.assertEquals(true, isEqualsFields(aCountry, 'Id', 'CountryId__c'));
        }
        Test.stopTest();
    }
    
    //Check two fields on equals on ProductCatalog object.
    private static testmethod void testProductCatalog()
    {
        Test.startTest();
        insert testObjectsMap.get('ProductCatalog__c');
        Set<Id> anInsertObjects = Util.getIdSet(testObjectsMap.get('ProductCatalog__c'));
        for (ProductCatalog__c aProductCatalog : selectProductCatalogByIds(anInsertObjects).values())
        {
            System.assertEquals(true, isEqualsFields(aProductCatalog));
        }
        
        update testObjectsMap.get('ProductCatalog__c');
        
        Set<Id> anUpdateObjects = Util.getIdSet(testObjectsMap.get('ProductCatalog__c'));
        for (ProductCatalog__c aProductCatalog : selectProductCatalogByIds(anUpdateObjects).values())
        {
            System.assertEquals(true, isEqualsFields(aProductCatalog));
        }
        Test.stopTest();
    }
    
    //Check two fields on equals on ProductCatalog object.
    private static testmethod void testAccountCountryName()
    {
        Test.startTest();
        Country__c countryToInsert = new Country__c(name='testCountry');
        insert countryToInsert;
        
        Country__c countryToInsert2 = new Country__c(name='testCountry2');
        insert countryToInsert2;
        
        Account accToInsert = new Account(name='testAccount', GC_country_name__c='testCountry');
        insert accToInsert;
        
        Account testAccountWithCountry = [Select id, name, countryref__c from account where id=:accToInsert.Id];
        
        Account accToInsert2 = new Account(name='testAccount2', countryRef__c=countryToInsert2.Id);
        insert accToInsert2;
        
        Account testAccountWithCountry2 = [Select id, name, countryref__c from account where id=:accToInsert2.Id];
        system.assertEquals(testAccountWithCountry2.countryRef__c, countryToInsert2.Id);
        
        Test.stopTest();
    }
    
    //Check on equals two certain fields of object.
    private static Boolean isEqualsFields(sObject theObject)
    {
        return isEqualsFields(theObject, 'CountryRef__c', 'CountryID__c');
    }
    
    //Check on equals two input fields of object.
    private static Boolean isEqualsFields(sObject theObject, String theFirstField, String theSecondField)
    {
        return theObject.get(theFirstField) == theObject.get(theSecondField);
    }
    
    //Select Country records from batadase by Ids
    private static Map<Id, ProductCatalog__c> selectProductCatalogByIds(Set<Id> theIdSet)
    {
        return new Map<Id, ProductCatalog__c>([SELECT CountryId__c, CountryRef__c FROM ProductCatalog__c WHERE Id IN :theIdSet]);
    }
    
    //Select ProductCatalog records from batadase by Ids
    private static Map<Id, Country__c> selectCoutryByIds(Set<Id> theIdSet)
    {
        return new Map<Id, Country__c>([SELECT CountryId__c FROM Country__c WHERE Id IN :theIdSet]);
    }
    
    //Create and add record to list of sObjects.
    private static void generatorObjects(String theApiName, Map<String, Object> theNameToValueMap)
    {
        testObjectsMap.get(theApiName).add(SmartFactory.createSObject(theApiName, theNameToValueMap));
    }
}