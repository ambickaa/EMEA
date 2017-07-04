@isTest
public class BudgetManagementControllerTest {

    static testMethod void Deletions() {
        Test_REST_DataFactoryEast.TestData();
        BudgetManagementController Controller = new BudgetManagementController();
        Controller.SelectedBudgetId=Test_REST_DataFactoryEast.Bud.id;
        Controller.doDelete();
    }
    static testMethod void SL() {
        Test_REST_DataFactoryEast.TestData();
        BudgetManagementController Controller = new BudgetManagementController();
        
        List<Schema.FieldSetMember> NewList = Controller.budgetfields;
        
            Controller.product=Test_REST_DataFactoryEast.pce;
            Controller.user=Util.currentuser;
            Controller.budgetfilter=Test_REST_DataFactoryEast.Bud;
            
        Controller.searchBudget();
        
        List<Budget__c> BL = Controller.BudgetList;
        Controller.previous();
        Boolean HP=Controller.hasPrevious;
        System.AssertEquals(HP,false);
        Controller.next();
        Boolean HN=Controller.hasNext;
        System.AssertEquals(HN,false);
        Integer PN=Controller.pagenumber;
    }
    static testMethod void DBSave() {
        BudgetManagementController Controller = new BudgetManagementController();
        Test_REST_DataFactoryEast.TestData();
            Controller.product=Test_REST_DataFactoryEast.pce;
            Controller.user=Util.currentuser;
            Controller.budgetfilter=Test_REST_DataFactoryEast.Bud;
        Controller.doSave();
    }
    static testMethod void DBSearch() {
        BudgetManagementController Controller = new BudgetManagementController();
        Test_REST_DataFactoryEast.TestData();
            Controller.product=Test_REST_DataFactoryEast.pce;
            Controller.user=Util.currentuser;
            Controller.budgetnewfilter=Test_REST_DataFactoryEast.Bud;
        Controller.SearchPCE();
    }
    static testMethod void DBSaveNew() {
        BudgetManagementController Controller = new BudgetManagementController();
        BudgetManagementController Controller2 = new BudgetManagementController();
        Test_REST_DataFactoryEast.TestData();
            Controller.product=Test_REST_DataFactoryEast.pce;
            Controller.user=Util.currentuser;
            Controller.budgetfilter=Test_REST_DataFactoryEast.Bud;
        Controller.doSaveNew();
        Controller.doNew();
        Controller.doCancelNew();
        Controller2.doSaveNew();
        Controller2.doNew();
       // Controller2.delLastNew(); 
        }
}