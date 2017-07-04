@IsTest
public with sharing class DeletePageControllerTest {
	 private static Account farm;
	private static Contact contact;
	
	public static testmethod void DeletePageAccWithID(){
		init();
		DeletePageController cont = new DeletePageController();
        
        cont.accToFind=farm.id;
        cont.clientCodes= false;
        cont.doFindAcc();
        cont.doDelete();
    }
    public static testmethod void DeletePageAccWithCC(){
		init();
		DeletePageController cont = new DeletePageController();
        farm= [SELECT ID, Client_Code__c FROM Account WHERE ID=: farm.Id];
        cont.accToFind=farm.Client_Code__c;
        cont.clientCodes= true;
        cont.doFindAcc();
        cont.doDelete();
    }
    public static testmethod void DeletePageContactWithID(){
		init();
		DeletePageController cont = new DeletePageController();
        
        cont.conToFind=contact.id;
        cont.monsantoIDs= false;
        cont.doFindCon();
        cont.doDelete();
    }
    public static testmethod void DeletePageContactWithMonsantoId(){
		init();
		DeletePageController cont = new DeletePageController();
        
        cont.conToFind=contact.DE_MonsantoID__c;
        cont.monsantoIDs = true;
        cont.doFindCon();
        cont.doDelete();
    }
    private static void init(){
    	SystemSettings__c s1 = new SystemSettings__c( Name='EAST_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s6 = new SystemSettings__c( Name='RSA_REST_SVC_JSON_SAVE',Value__C='4');
        SystemSettings__c s7 = new SystemSettings__c( Name='RSA_STOCK_THRESHOLD',Value__C='4');     
        SystemSettings__c s2 = new SystemSettings__c( Name='VAT_RSA',Value__C='0.14');
        SystemSettings__c s3 = new SystemSettings__c( Name='VAT_value0_RSA',Value__C='0');
        SystemSettings__c s4 = new SystemSettings__c( Name='EAST_RESET',Value__C='false');
        SystemSettings__c s5 = new SystemSettings__c( Name='EAST_RESET_DATE',Value__C='str');
        
        List<SystemSettings__c> ssList= new List<SystemSettings__c>{s1,s2,s3,s4,s5,s6,s7};
        insert ssList;
        
        
        Country__c c = new Country__c(Name ='Ukraine', TacticalPlanSetting__c = 'Standard');      
            insert c;
       
            
        farm= new Account (CountryRef__c=c.ID, Name='FarmTest',RecordTypeId=Util.recordType.get('Account:GroupFarmSite'),
                           Category__c='Farm' );
       contact= new Contact(LastName='Van',CountryRef__c=c.id, idDevice__c='900', 
             AccountId=farm.Id, DE_MonsantoID__c='ccc');
                           
		insert farm;
		insert contact;
        
    }
}