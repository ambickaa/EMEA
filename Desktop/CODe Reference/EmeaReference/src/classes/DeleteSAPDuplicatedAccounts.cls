//----------------------------------------------
// DeleteSAPDuplicatedAccounts
// By eCIP Support Team - April 16
// The following Apex class has been developed in order to remove from CIP
// the duplicated accounts from SAP in France, on April 16.
// April 15 update has transformed the behabiour of the class.
// Now it transfers all data related to a given account to another.
//----------------------------------------------
public with sharing class DeleteSAPDuplicatedAccounts {
	
	private Map<Id, Id> Map_Accounts = new Map<Id, Id>();
	public List<Account> List_From_Account {get; set;}
	public List<Account> List_To_Account {get; set;}
	
	public Integer ListSize {get; set;}
	public String From_Id {get; set;}
	public String To_Id {get; set;}
	
	public List<Action_Plan_Line__c> List_Action_Plan_Lines {get; set;}
	public List<Partner_Function__c> List_Partner_Functions {get; set;}
	public List<CampaignLineItemGroup__c> List_CLIGroups {get; set;}
	public List<Sales_Area__c> List_Sales_Areas {get; set;}
	public List<CampaignLineItem__c> List_CLIs {get; set;}
	public List<Delivery__c> List_Deliveries {get; set;}
	public List<Acreage__c> List_Acreages {get; set;}
	public List<Voucher__c> List_Vouchers {get; set;}
	public List<Invoice__c> List_Invoices {get; set;}
	public List<Banking__c> List_Bankings {get; set;}
	public List<Contract> List_Contracts {get; set;}
	public List<Contact> List_Contacts {get; set;}
	public List<Trial__c> List_Trials {get; set;}
	public List<Event> List_Events {get; set;}
	public List<Order> List_Orders {get; set;}
	public List<EDI__c> List_EDIs {get; set;}
	public List<Case> List_Cases {get; set;}
	public List<Task> List_Tasks {get; set;}
	
	public Boolean doPartnerFunctions {get; set;}
	public Boolean doActionPlanLines {get; set;}
	public Boolean doSalesAreas {get; set;}
	public Boolean doDeliveries {get; set;}
	public Boolean doContracts {get; set;}
	public Boolean doCLIGroups {get; set;}
	public Boolean doContacts {get; set;}
	public Boolean doAcreages {get; set;}
	public Boolean doVouchers {get; set;}
	public Boolean doInvoices {get; set;}
	public Boolean doBankings {get; set;}
	public Boolean doTrials {get; set;}
	public Boolean doEvents {get; set;}
	public Boolean doOrders {get; set;}
	public Boolean doCases {get; set;}
	public Boolean doTasks {get; set;}
	public Boolean doCLIs {get; set;}
	public Boolean doEDIs {get; set;}

/*
	public List<Note> List_Notes {get; set;}
	public List<Attachment> List_Attachments {get; set;}
*/

	public DeleteSAPDuplicatedAccounts() {
		
		Init();
		
	}
	
	public void Init() {
		
		//----------------------------------------------
		// All variables are initialized in Init method
		//----------------------------------------------
		ListSize = 0;
		From_Id = '';
		To_Id = '';

		List_From_Account = new List<Account>();
		List_To_Account = new List<Account>();
		Map_Accounts = new Map<Id, Id>();
		
		ReInit();
		
	}
	
	public void ReInit() {
		
		List_Partner_Functions = new List<Partner_Function__c>();
		List_Action_Plan_Lines = new List<Action_Plan_Line__c>();
		List_CLIGroups = new List<CampaignLineItemGroup__c>();
		List_Sales_Areas = new List<Sales_Area__c>();
		List_CLIs = new List<CampaignLineItem__c>();
		List_Deliveries = new List<Delivery__c>();
		List_Acreages = new List<Acreage__c>();
		List_Vouchers = new List<Voucher__c>();
		List_Invoices = new List<Invoice__c>();
		List_Bankings = new List<Banking__c>();
		List_Contracts = new List<Contract>();
		List_Contacts = new List<Contact>();
		List_Trials = new List<Trial__c>();
		List_Orders = new List<Order>();
		List_Events = new List<Event>();
		List_EDIs = new List<EDI__c>();
		List_Tasks = new List<Task>();
		List_Cases = new List<Case>();

/*
		List_Notes = new List<Note>();
		List_Attachments = new List<Attachment>();
*/

	}
		
	public void doSearch() {
		
		ReInit();
		
		//----------------------------------------------
		// All lists and maps need to be refreshed when calling method doSearch
		//----------------------------------------------
		
		List_From_Account = new List<Account>();
		List_To_Account = new List<Account>();
		Map_Accounts = new Map<Id, Id>();

		if(validateId(From_Id) == null || validateId(To_Id) == null) {
			
			if(validateId(From_Id) == null)
				Util.addInfoMessage('The input text "' + From_Id + '" is not an Id.');
			
			if(validateId(To_Id) == null)
				Util.addInfoMessage('The input text "' + To_Id + '" is not an Id.');
				
		} else {
			
			for(Account acc : [SELECT Id, Name, Owner.Name, Owner.Alias, OwnerId, CountryRef__c, GC_Status_Descr__c, Client_Code__c
											FROM Account
											WHERE Id = : From_Id OR Id = : To_Id]) {
			
				//----------------------------------------------
				// FROM account
				//----------------------------------------------
				if(acc.Id == From_Id)
					List_From_Account.add(acc);
				
				//----------------------------------------------
				// TO account
				//----------------------------------------------
				if(acc.Id == To_Id)
					List_To_Account.add(acc);

			}
			
			if(List_From_Account.size() > 0 && List_To_Account.size() > 0) {
				Map_Accounts.put(From_Id, To_Id);
				doTransfer();
			}
			
		}
		
	}
	
	public void doTransfer() {
		
		//----------------------------------------------
		// 1. PARTNER FUNCTIONS
		//----------------------------------------------
		for(Partner_Function__c SAP : [SELECT Id, Name, Primry_Acct_Integration_Key__c
											FROM Partner_Function__c
											WHERE Primry_Acct_Integration_Key__c = : From_Id]) {
			
			SAP.Primry_Acct_Integration_Key__c = Map_Accounts.get(SAP.Primry_Acct_Integration_Key__c);
			List_Partner_Functions.add(SAP);
		}
		
		//----------------------------------------------
		// 2. INVOICES
		//----------------------------------------------
		for(Invoice__c SAP : [SELECT Id, Name, GC_Account_Integration_Key__c, ShipTo_Acc_Integration_Key__c
											FROM Invoice__c
											WHERE GC_Account_Integration_Key__c = : From_Id
											OR ShipTo_Acc_Integration_Key__c = : From_Id]) {
			
			SAP.GC_Account_Integration_Key__c = Map_Accounts.containsKey(SAP.GC_Account_Integration_Key__c) ? Map_Accounts.get(SAP.GC_Account_Integration_Key__c) : SAP.GC_Account_Integration_Key__c;
			SAP.ShipTo_Acc_Integration_Key__c = Map_Accounts.containsKey(SAP.ShipTo_Acc_Integration_Key__c) ? Map_Accounts.get(SAP.ShipTo_Acc_Integration_Key__c) : SAP.ShipTo_Acc_Integration_Key__c;
			List_Invoices.add(SAP);
		}
		
		//----------------------------------------------
		// 3. ORDERS
		//----------------------------------------------		
		for(Order SAP : [SELECT Id, Name, AccountId, ShipTo_Acc_Integration_Key__c
											FROM Order
											WHERE AccountId = : From_Id
											OR ShipTo_Acc_Integration_Key__c = : From_Id]) {
			
			SAP.AccountId = Map_Accounts.containsKey(SAP.AccountId) ? Map_Accounts.get(SAP.AccountId) : SAP.AccountId;
			SAP.ShipTo_Acc_Integration_Key__c = Map_Accounts.containsKey(SAP.ShipTo_Acc_Integration_Key__c) ? Map_Accounts.get(SAP.ShipTo_Acc_Integration_Key__c) : SAP.ShipTo_Acc_Integration_Key__c;
			List_Orders.add(SAP);
		}
		
		//----------------------------------------------
		// 4. DELIVERIES
		//----------------------------------------------		
		for(Delivery__c SAP : [SELECT Id, Name, GC_Account_Integration_Key__c, ShipTo_Acc_Integration_Key__c
											FROM Delivery__c
											WHERE GC_Account_Integration_Key__c = : From_Id
											OR ShipTo_Acc_Integration_Key__c = : From_Id]) {
			
			SAP.GC_Account_Integration_Key__c = Map_Accounts.containsKey(SAP.GC_Account_Integration_Key__c) ? Map_Accounts.get(SAP.GC_Account_Integration_Key__c) : SAP.GC_Account_Integration_Key__c;
			SAP.ShipTo_Acc_Integration_Key__c = Map_Accounts.containsKey(SAP.ShipTo_Acc_Integration_Key__c) ? Map_Accounts.get(SAP.ShipTo_Acc_Integration_Key__c) : SAP.ShipTo_Acc_Integration_Key__c;
			List_Deliveries.add(SAP);
		}
		
		//----------------------------------------------
		// 5. CONTRACTS
		//----------------------------------------------		
		for(Contract SAP : [SELECT Id, Name, AccountId, ShipTo_Acc_Integration_Key__c
											FROM Contract
											WHERE AccountId = : From_Id
											OR ShipTo_Acc_Integration_Key__c = : From_Id]) {
			
			SAP.AccountId = Map_Accounts.containsKey(SAP.AccountId) ? Map_Accounts.get(SAP.AccountId) : SAP.AccountId;
			SAP.ShipTo_Acc_Integration_Key__c = Map_Accounts.containsKey(SAP.ShipTo_Acc_Integration_Key__c) ? Map_Accounts.get(SAP.ShipTo_Acc_Integration_Key__c) : SAP.ShipTo_Acc_Integration_Key__c;
			List_Contracts.add(SAP);
		}
		
		//----------------------------------------------
		// 6. CASES
		//----------------------------------------------
		for(Case SAP : [SELECT Id, CaseNumber, AccountId, GC_Secondary_Account_SFID__c,
											RecordTypeId
											FROM Case
											WHERE AccountId = : From_Id
											OR GC_Secondary_Account_SFID__c = : From_Id]) {
			
			SAP.AccountId = Map_Accounts.containsKey(SAP.AccountId) ? Map_Accounts.get(SAP.AccountId) : SAP.AccountId;
			SAP.GC_Secondary_Account_SFID__c = Map_Accounts.containsKey(SAP.GC_Secondary_Account_SFID__c) ? Map_Accounts.get(SAP.GC_Secondary_Account_SFID__c) : SAP.GC_Secondary_Account_SFID__c;
			List_Cases.add(SAP);
		}
		
		//----------------------------------------------
		// 7. SALES AREAS
		//----------------------------------------------
		for(Sales_Area__c SAP : [SELECT Id, Name, GC_Account_Integration_Key__c
											FROM Sales_Area__c
											WHERE GC_Account_Integration_Key__c = : From_Id]) {
			
			SAP.GC_Account_Integration_Key__c = Map_Accounts.get(SAP.GC_Account_Integration_Key__c);
			List_Sales_Areas.add(SAP);
		}
		
		//----------------------------------------------
		// 8. CONTACTS
		//----------------------------------------------
		for(Contact SAP : [SELECT Id, Name, AccountId,
											Firstname, Lastname, Status__c
											FROM Contact
											WHERE AccountId = : From_Id]) {
			
			SAP.AccountId = Map_Accounts.get(SAP.AccountId);
			List_Contacts.add(SAP);
		}
		
		//----------------------------------------------
		// 9. EDI
		//----------------------------------------------
		for(EDI__c SAP : [SELECT Id, Name, GC_Account_Integration_Key__c
											FROM EDI__c
											WHERE GC_Account_Integration_Key__c = : From_Id]) {
			
			SAP.GC_Account_Integration_Key__c = Map_Accounts.get(SAP.GC_Account_Integration_Key__c);
			List_EDIs.add(SAP);
		}
		
		//----------------------------------------------
		// 10. BANKING
		//----------------------------------------------
		for(Banking__c SAP : [SELECT Id, Name, GC_Account_Integration_Key__c
											FROM Banking__c
											WHERE GC_Account_Integration_Key__c = : From_Id]) {
			
			SAP.GC_Account_Integration_Key__c = Map_Accounts.get(SAP.GC_Account_Integration_Key__c);
			List_Bankings.add(SAP);
		}
		
		//----------------------------------------------
		// 11. ACTION PLAN LINES
		//----------------------------------------------
		for(Action_Plan_Line__c SAP : [SELECT Id, Name, LKP_Account__c
											FROM Action_Plan_Line__c
											WHERE LKP_Account__c = : From_Id]) {
			
			SAP.LKP_Account__c = Map_Accounts.get(SAP.LKP_Account__c);
			List_Action_Plan_Lines.add(SAP);
		}
			
		//----------------------------------------------
		// 12. ACREAGES
		//----------------------------------------------
		for(Acreage__c SAP : [SELECT Id, Name, AcrFarmRef__c, AcrProviderRef__c, AcrYearRef__c,
										AcrTotalAcreages__c, AcrProductGroupRef__c, AcrProductTypeRef__c
										FROM Acreage__c
										WHERE AcrFarmRef__c = : From_Id
										OR AcrProviderRef__c = : From_Id]) {
		
			SAP.AcrFarmRef__c = Map_Accounts.containsKey(SAP.AcrFarmRef__c) ? Map_Accounts.get(SAP.AcrFarmRef__c) : SAP.AcrFarmRef__c;
			SAP.AcrProviderRef__c = Map_Accounts.containsKey(SAP.AcrProviderRef__c) ? Map_Accounts.get(SAP.AcrProviderRef__c) : SAP.AcrProviderRef__c;
			List_Acreages.add(SAP);
		}
		
		//----------------------------------------------
		// 13. VOUCHERS
		//----------------------------------------------
		for(Voucher__c SAP : [SELECT Id, Name, AccountRef__c, DistributorRef__c,
										Status__c, sentMail__c, CampaignRef__c
										FROM Voucher__c
										WHERE AccountRef__c = : From_Id
										OR DistributorRef__c = : From_Id]) {
		
			SAP.AccountRef__c = Map_Accounts.containsKey(SAP.AccountRef__c) ? Map_Accounts.get(SAP.AccountRef__c) : SAP.AccountRef__c;
			SAP.DistributorRef__c = Map_Accounts.containsKey(SAP.DistributorRef__c) ? Map_Accounts.get(SAP.DistributorRef__c) : SAP.DistributorRef__c;
			List_Vouchers.add(SAP);
		}
		
		//----------------------------------------------
		// 14. CLI GROUPS
		//----------------------------------------------
		for(CampaignLineItemGroup__c SAP : [SELECT Id, Name, AccountRef__c
										FROM CampaignLineItemGroup__c
										WHERE AccountRef__c = : From_Id]) {
		
			SAP.AccountRef__c = Map_Accounts.get(SAP.AccountRef__c);
			List_CLIGroups.add(SAP);
		}
		
		//----------------------------------------------
		// 15. CLIS
		//----------------------------------------------
		for(CampaignLineItem__c SAP : [SELECT Id, Name, FarmRef__c, PoS__c, DistributorRef__c,
										Quantity__c, QuantityFOC__c, Status__c, CampaignRef__c
										FROM CampaignLineItem__c
										WHERE PoS__c = : From_Id
										OR FarmRef__c = : From_Id
										OR DistributorRef__c = : From_Id
										OR DE_DistributorRef__c = : From_Id
										OR LKP_DistributorRefST__c = : From_Id]) {
		
			SAP.PoS__c = Map_Accounts.containsKey(SAP.PoS__c) ? Map_Accounts.get(SAP.PoS__c) : SAP.PoS__c;
			SAP.FarmRef__c = Map_Accounts.containsKey(SAP.FarmRef__c) ? Map_Accounts.get(SAP.FarmRef__c) : SAP.FarmRef__c;
			SAP.DistributorRef__c = Map_Accounts.containsKey(SAP.DistributorRef__c) ? Map_Accounts.get(SAP.DistributorRef__c) : SAP.DistributorRef__c;
			SAP.DE_DistributorRef__c = Map_Accounts.containsKey(SAP.DE_DistributorRef__c) ? Map_Accounts.get(SAP.DE_DistributorRef__c) : SAP.DE_DistributorRef__c;
			SAP.LKP_DistributorRefST__c = Map_Accounts.containsKey(SAP.LKP_DistributorRefST__c) ? Map_Accounts.get(SAP.LKP_DistributorRefST__c) : SAP.LKP_DistributorRefST__c;
			List_CLIs.add(SAP);
		}
		
		//----------------------------------------------
		// 16. TRIALS
		//----------------------------------------------
		for(Trial__c SAP : [SELECT Id, Name, AccountRef__c, LKP_DistributorAccountPartner__c
										FROM Trial__c
										WHERE AccountRef__c = : From_Id
										OR LKP_DistributorAccountPartner__c = : From_Id]) {
		
			SAP.AccountRef__c = Map_Accounts.containsKey(SAP.AccountRef__c) ? Map_Accounts.get(SAP.AccountRef__c) : SAP.AccountRef__c;
			SAP.LKP_DistributorAccountPartner__c = Map_Accounts.containsKey(SAP.LKP_DistributorAccountPartner__c) ? Map_Accounts.get(SAP.LKP_DistributorAccountPartner__c) : SAP.LKP_DistributorAccountPartner__c;
			List_Trials.add(SAP);
		}
		
		//----------------------------------------------
		// 19. EVENTS
		//----------------------------------------------
		for(Event SAP : [SELECT Id, WhatId
										FROM Event
										WHERE WhatId = : From_Id]) {
		
			SAP.WhatId = Map_Accounts.get(SAP.WhatId);
			List_Events.add(SAP);
		}
		
		//----------------------------------------------
		// 20. TASKS
		//----------------------------------------------
		for(Task SAP : [SELECT Id, WhatId
										FROM Task
										WHERE WhatId = : From_Id]) {
		
			SAP.WhatId = Map_Accounts.get(SAP.WhatId);
			List_Tasks.add(SAP);
		}
		
/*
		//----------------------------------------------
		// 21. NOTES
		//----------------------------------------------
		for(Note SAP : [SELECT Id, ParentId
										FROM Note
										WHERE ParentId = : From_Id]) {
		
			SAP.ParentId = Map_Accounts.get(SAP.ParentId);
			List_Notes.add(SAP);
		}
		
		//----------------------------------------------
		// 22. ATTACHMENTS
		//----------------------------------------------
		for(Attachment SAP : [SELECT Id, ParentId
										FROM Attachment
										WHERE ParentId = : From_Id]) {
		
			SAP.ParentId = Map_Accounts.get(SAP.ParentId);
			List_Attachments.add(SAP);
		}
*/
		
		//----------------------------------------------
		// Once all data has been retrieved, update actions are called
		//----------------------------------------------
		ListSize = List_From_Account.size() +  List_To_Account.size();
		
		ListSize += List_Partner_Functions.size();
		ListSize += List_Action_Plan_Lines.size();
		ListSize += List_Sales_Areas.size();
		ListSize += List_CLIGroups.size();
		ListSize += List_Contracts.size();
		ListSize += List_Contacts.size();
		ListSize += List_Bankings.size();
		ListSize += List_Invoices.size();
		ListSize += List_Acreages.size();
		ListSize += List_Vouchers.size();
		ListSize += List_Trials.size();
		ListSize += List_Events.size();
		ListSize += List_Orders.size();
		ListSize += List_Tasks.size();
		ListSize += List_Cases.size();
		ListSize += List_CLIs.size();
		ListSize += List_EDIs.size();
		
		Util.addInfoMessage('Search process completed.');
		
		if(ListSize == 2) Util.addInfoMessage('No items to transfer.');
		
		doPartnerFunctions = List_Partner_Functions.size() > 0 ? true : false;
		doActionPlanLines = List_Action_Plan_Lines.size() > 0 ? true : false;
		doSalesAreas = List_Sales_Areas.size() > 0 ? true : false;
		doDeliveries = List_Deliveries.size() > 0 ? true : false;
		doContracts = List_Contracts.size() > 0 ? true : false;
		doCLIGroups = List_CLIGroups.size() > 0 ? true : false;
		doContacts = List_Contacts.size() > 0 ? true : false;
		doAcreages = List_Acreages.size() > 0 ? true : false;
		doVouchers = List_Vouchers.size() > 0 ? true : false;
		doInvoices = List_Invoices.size() > 0 ? true : false;
		doBankings = List_Bankings.size() > 0 ? true : false;
		doTrials = List_Trials.size() > 0 ? true : false;
		doEvents = List_Events.size() > 0 ? true : false;
		doOrders = List_Orders.size() > 0 ? true : false;
		doCases = List_Cases.size() > 0 ? true : false;
		doTasks = List_Tasks.size() > 0 ? true : false;
		doEDIs = List_EDIs.size() > 0 ? true : false;
		doCLIs = List_CLIs.size() > 0 ? true : false;
		
	}
	
	public void doTransferX() {
		
		//----------------------------------------------
		// The process will stopped if Query Limit or CPU Time limit is reached,
		// contained into a certain security range/margin
		//----------------------------------------------
		Integer QueryLimitMargin = 2;
		Integer CPULimitMargin = 100;
		Boolean Out = Limits.getCpuTime() >= (Limits.getLimitCpuTime() - CPULimitMargin) || Limits.getQueries() >= (Limits.getLimitQueries() - QueryLimitMargin) ? true : false;
		
		//----------------------------------------------
		// The process will be only triggered if it does not reach the DML limit
		//----------------------------------------------
		if(ListSize + Limits.getDMLRows() < Limits.getLimitDMLRows()) {

			System.savepoint sp = Database.setSavepoint();
				
			try {
				
				if(!Out && List_Partner_Functions.size() > 0 && doPartnerFunctions)
					update List_Partner_Functions;
					
				Out = Out || Limits.getCpuTime() >= (Limits.getLimitCpuTime() - CPULimitMargin) || Limits.getQueries() >= (Limits.getLimitQueries() - QueryLimitMargin) ? true : false;
					
				if(!Out && List_Action_Plan_Lines.size() > 0 && doActionPlanLines)
					update List_Action_Plan_Lines;
					
				Out = Out || Limits.getCpuTime() >= (Limits.getLimitCpuTime() - CPULimitMargin) || Limits.getQueries() >= (Limits.getLimitQueries() - QueryLimitMargin) ? true : false;
				
				if(!Out && List_Sales_Areas.size() > 0 && doSalesAreas)
					update List_Sales_Areas;
					
				Out = Out || Limits.getCpuTime() >= (Limits.getLimitCpuTime() - CPULimitMargin) || Limits.getQueries() >= (Limits.getLimitQueries() - QueryLimitMargin) ? true : false;
				
				if(!Out && List_Deliveries.size() > 0 && doDeliveries)
					update List_Deliveries;
					
				Out = Out || Limits.getCpuTime() >= (Limits.getLimitCpuTime() - CPULimitMargin) || Limits.getQueries() >= (Limits.getLimitQueries() - QueryLimitMargin) ? true : false;
				
				if(!Out && List_Contracts.size() > 0 && doContracts)
					update List_Contracts;
					
				Out = Out || Limits.getCpuTime() >= (Limits.getLimitCpuTime() - CPULimitMargin) || Limits.getQueries() >= (Limits.getLimitQueries() - QueryLimitMargin) ? true : false;
					
				if(!Out && List_Contacts.size() > 0 && doContacts)
					update List_Contacts;
					
				Out = Out || Limits.getCpuTime() >= (Limits.getLimitCpuTime() - CPULimitMargin) || Limits.getQueries() >= (Limits.getLimitQueries() - QueryLimitMargin) ? true : false;
				
				if(!Out && List_Cases.size() > 0 && doCases)
					update List_Cases;
					
				Out = Out || Limits.getCpuTime() >= (Limits.getLimitCpuTime() - CPULimitMargin) || Limits.getQueries() >= (Limits.getLimitQueries() - QueryLimitMargin) ? true : false;
				
				if(!Out && List_Bankings.size() > 0 && doBankings)
					update List_Bankings;
					
				Out = Out || Limits.getCpuTime() >= (Limits.getLimitCpuTime() - CPULimitMargin) || Limits.getQueries() >= (Limits.getLimitQueries() - QueryLimitMargin) ? true : false;
				
				if(!Out && List_Invoices.size() > 0 && doInvoices)
					update List_Invoices;
					
				Out = Out || Limits.getCpuTime() >= (Limits.getLimitCpuTime() - CPULimitMargin) || Limits.getQueries() >= (Limits.getLimitQueries() - QueryLimitMargin) ? true : false;
				
				if(!Out && List_Orders.size() > 0 && doOrders)
					update List_Orders;
					
				Out = Out || Limits.getCpuTime() >= (Limits.getLimitCpuTime() - CPULimitMargin) || Limits.getQueries() >= (Limits.getLimitQueries() - QueryLimitMargin) ? true : false;
				
				if(!Out && List_EDIs.size() > 0 && doEDIs)
					update List_EDIs;
					
				Out = Out || Limits.getCpuTime() >= (Limits.getLimitCpuTime() - CPULimitMargin) || Limits.getQueries() >= (Limits.getLimitQueries() - QueryLimitMargin) ? true : false;
				
				if(!Out && List_Acreages.size() > 0 && doAcreages)
					update List_Acreages;
				
				Out = Out || Limits.getCpuTime() >= (Limits.getLimitCpuTime() - CPULimitMargin) || Limits.getQueries() >= (Limits.getLimitQueries() - QueryLimitMargin) ? true : false;
				
				if(!Out && List_Vouchers.size() > 0 && doVouchers)
					update List_Vouchers;
				
				Out = Out || Limits.getCpuTime() >= (Limits.getLimitCpuTime() - CPULimitMargin) || Limits.getQueries() >= (Limits.getLimitQueries() - QueryLimitMargin) ? true : false;
				
				if(!Out && List_CLIGroups.size() > 0 && doCLIGroups)
					update List_CLIGroups;
				
				Out = Out || Limits.getCpuTime() >= (Limits.getLimitCpuTime() - CPULimitMargin) || Limits.getQueries() >= (Limits.getLimitQueries() - QueryLimitMargin) ? true : false;
				
				if(!Out && List_CLIs.size() > 0 && doCLIs)
					update List_CLIs;
				
				Out = Out || Limits.getCpuTime() >= (Limits.getLimitCpuTime() - CPULimitMargin) || Limits.getQueries() >= (Limits.getLimitQueries() - QueryLimitMargin) ? true : false;
				
				if(!Out && List_Trials.size() > 0 && doTrials)
					update List_Trials;
				
				Out = Out || Limits.getCpuTime() >= (Limits.getLimitCpuTime() - CPULimitMargin) || Limits.getQueries() >= (Limits.getLimitQueries() - QueryLimitMargin) ? true : false;
				
				if(!Out && List_Events.size() > 0 && doEvents)
					update List_Events;
				
				Out = Out || Limits.getCpuTime() >= (Limits.getLimitCpuTime() - CPULimitMargin) || Limits.getQueries() >= (Limits.getLimitQueries() - QueryLimitMargin) ? true : false;
				
				if(!Out && List_Tasks.size() > 0 && doTasks)
					update List_Tasks;
				
				/*
				Out = Out || Limits.getCpuTime() >= (Limits.getLimitCpuTime() - CPULimitMargin) || Limits.getQueries() >= (Limits.getLimitQueries() - QueryLimitMargin) ? true : false;
				
				if(!Out && List_Notes.size() > 0)
					update List_Notes;
				
				Out = Out || Limits.getCpuTime() >= (Limits.getLimitCpuTime() - CPULimitMargin) || Limits.getQueries() >= (Limits.getLimitQueries() - QueryLimitMargin) ? true : false;
				
				if(!Out && List_Attachments.size() > 0)
					update List_Attachments;
				*/
				//----------------------------------------------
				// Success for transfer process
				//----------------------------------------------
				if(!Out) {
					
					Util.addConfirmMessage('Process completed successfully.');
					Util.addConfirmMessage('Number of queries used in this Apex code: ' + Limits.getQueries());
					Util.addConfirmMessage('Number of rows queried in this Apex code: ' + Limits.getDmlRows());
					Util.addConfirmMessage('Number of script statements used: ' +  Limits.getDmlStatements());
					Util.addConfirmMessage('Amount of CPU time (in ms) used: ' + Limits.getCpuTime());
					Init();
				}
	
			} catch(Exception e) {
				
				Database.rollback(sp);
				
				Init();
				Util.addErrorMessage('Process failed due to ' + e.getMessage());
				Util.addErrorMessage('No rows processes. Rollback successful.');
			}
			
			//----------------------------------------------
			// Exceptions
			//----------------------------------------------
			if(Out) {
				
				Database.rollback(sp);
				Init();
				
				Util.addErrorMessage('No rows processes. Rollback successful.');
			}
			
			//----------------------------------------------
			// Exceptions for cases in which the number of queries is reaching the limit
			//----------------------------------------------
			if(Out && Limits.getQueries() >= (Limits.getLimitQueries() - QueryLimitMargin))
				Util.addErrorMessage('The process was stopped because the number of queries (' + Limits.getQueries() + ') was reaching the limit of ' + (Limits.getLimitQueries() - QueryLimitMargin));
			
			//----------------------------------------------
			// Exceptions for cases in which the CPU time is exceeded
			//----------------------------------------------
			if(Out && Limits.getCpuTime() >= (Limits.getLimitCpuTime() - CPULimitMargin))
				Util.addErrorMessage('The process was stopped because the CPU time (' + Limits.getCpuTime() + ' ms) was reaching the limit of ' + (Limits.getLimitCpuTime() - CPULimitMargin) + ' ms.');
				

		} else {
				
			Init();
			Util.addWarningMessage('Trying to update ' + ListSize + ' records but governor limits will only allow ' + Limits.getLimitDMLRows());
			Util.addWarningMessage('No rows processes.');
		}
		
	}
	
	//----------------------------------------------
	// Method to validate ids
	//----------------------------------------------
	static public String validateId(String Idparam) {
		String id = String.escapeSingleQuotes(Idparam);
		if((id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id))
    		return id;
    	return null;
	}


}