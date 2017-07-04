/**
 * This class provides methods for inline vf page to show contracts related to account
 * and search based on certain criteria.
 * 
 * @author	Accenture
 * @version	1.0, 04/11/2016
 * 
 */ 
public class ContractsController extends ODICommons{
    public List<Contract> lstContracts;
    public String fiscalYear{get;set;}
    public Report oReport{get;set;}
    public List<SelectOption> lstFiscalYears{
        get{
            if(lstFiscalYears == null){
                lstFiscalYears = new List<SelectOption>();
                lstFiscalYears.add(new SelectOption('','All'));
                try{
                    for(String year : Label.Fiscal_Year.split(',')){
                        lstFiscalYears.add(new SelectOption(year,year));
                    }
                    lstFiscalYears.sort();
                }catch(Exception e){system.debug('ERROR:'+e.getMessage());}
            }
            return lstFiscalYears;
        }
        set;
    }
    
    public ContractsController(Apexpages.StandardController con){
        oReport = getReport(Label.Account_with_Standard_Contract);
    }
    
    /**
     * This method constructs query for fetching contract records based on the filter criteria
     * 
     * @param	Nothing
     * @returns Query as string
     * @throws	Nothing
     * @since	1.0
     * 
     */
    public override String getQuery(){
        String query = 'SELECT Id,fGC_Ship_To_ID__c,LastModifiedDate,ContractNumber,AccountId'
            			+',Account.Name,PO_Number_Text__c,Document_Date__c,Total_Contract_Qty__c'
            			+',CalledOff_Contract_Qty__c,OutStanding_Contract_Qty__c,GC_Integration_Key__c'
            			+',ShipToParty_Name_Text__c'
            			+' FROM Contract'
            			+' WHERE (AccountId = :accountId OR ShipTo_Acc_Integration_Key__c = :accountId)';
        if(fiscalYear != null){
            query += ' AND FISCAL_YEAR(Document_Date__c) = '+Integer.valueOf(fiscalYear);
        }
        if(division != null){
            query += ' AND Divison_Code__c = :division';
        }
        if(salesOrg != null){
            query += ' AND Sales_Org_Code__c = :salesOrg';
        }
        query+=' ORDER BY LastModifiedDate DESC' 
                 +' LIMIT :REC_LIMIT';
        return query;
    }
    
    /**
     * This method returns the next set of records based on pagination
     * 
     * @param	Nothing
     * @returns	List of contract records
     * @throws	Nothing
     * @since	1.0
     * 
     */
    public List<Contract> getLstContracts(){
        return (List<Contract>)con.getRecords();
    }
    
    /**
     * This method call the search based on the criteiria chosen by user
     * 
     * @param	Nothing
     * @returns	Nothing
     * @throws	Nothing
     * @since	1.0
     * 
     */
    public void search(){
        con = null;//set con to null so that query should be fired again
    	getLstContracts();// get fresh list of contracts
    }
}