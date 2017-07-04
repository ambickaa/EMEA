@isTest
public class UtilClass_Test 
{
    public static final String CLASSNAME = 'Test_ClassName';
    public static final String METHODNAME = 'Test_MethodName';
    static testMethod void testDMLEXceptionLoggin()
    {
        Case newCase = new Case();
        List<AdminEmailGroup__c> listOfAdminEmailGroup = new List<AdminEmailGroup__c>();
        List<Case> listOfCases = new List<Case>();
        listOfAdminEmailGroup = ACSTestDataFactory.generateAdminEmailGroup(1);
        if(!listOfAdminEmailGroup.isEmpty())
        {
            insert listOfAdminEmailGroup;
        }
        try
        {
            insert newCase;
            delete newCase;
            // raising dml exception ;P
            update newCase;
        }
        catch(Exception testException)
        {
            UtilClass.logException(CLASSNAME,METHODNAME,testException);
        }
        try
        {
            listOfCases[0].Origin = '';
        }
        catch(Exception testException)
        {
            UtilClass.logException(CLASSNAME,METHODNAME,testException);
        }
    }
}