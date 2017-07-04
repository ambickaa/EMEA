@isTest
private class AccountFarmUpdateBatchableTest {
	
    static testMethod void StartTest() {
    	Test_REST_DataFactoryEast.TestData();
    	List<Account> RetList=Test_REST_DataFactoryEast.aList;
    	
    	Test.startTest();
		AccountFarmUpdateBatchable job = new AccountFarmUpdateBatchable();
		ID batchprocessid = Database.executeBatch(job);
		Test.stopTest();
    }
}