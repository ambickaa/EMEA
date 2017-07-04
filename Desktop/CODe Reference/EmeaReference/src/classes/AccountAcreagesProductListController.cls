public with sharing class AccountAcreagesProductListController  extends AccountListVirtualController
{
	public static String JUMPER_ACREAGES = 'AccountAcreageProductList';
	public static final Set<String> READ_ONLY_FIELDS = new Set<String> {'AcrProviderRef__c', 'AcrProductGroupRef__c',
			  'AcrProductTypeRef__c', 'AcrLastModified__c'};

	public AccountAcreagesProductListController()
	{
		jumperTag = JUMPER_ACREAGES;
		mode = 'acreageProductEdit';
		fieldSetManager = new AcreagesFieldManager();
		AcreageFactory aFactory = new AcreageFactory(true);
		objectFactory = aFactory; 
		for(String aField : fieldSetManager.getSOQLFields())
		{
			aFactory.selectFields.add(aField);
		}
	}

	public AcreagesFieldManager getAcreageFieldSetManager()
	{
		return (AcreagesFieldManager) fieldSetManager;
	}
	
	public List<Acreage> getMerchandiseManagements()
	{
		return (List<Acreage>) wrapperObjects;
	}
	
	public List<Acreage> getAcreageList()
	{
		return (List<Acreage>) wrapperObjects;
	}
	

	public class AcreagesFieldManager extends FieldSetMemberxManager
	{
		public AcreagesFieldManager()
		{
			super(Schema.SObjectType.Acreage__c, JUMPER_ACREAGES);
		}
		
		protected override FieldSetMemberx createFieldSetMember(FieldSetMember theMember)
		{
			return new AcreagesFieldMember(theMember);
		}
		
		public List<AcreagesFieldMember> getAcreageFieldMembers()
		{
			List<AcreagesFieldMember> aReturn  = new List<AcreagesFieldMember>();
			for (FieldSetMemberx aMember: managedFieldSetMembers)
			{
				aReturn.add((AcreagesFieldMember)aMember);
			}
			return aReturn;
		}
	}
	
	public class AcreagesFieldMember extends FieldSetMemberx
	{
		public Boolean isPrevField{get;set;}
		
		public AcreagesFieldMember(FieldSetMember theMember)
		{
			super(theMember);
			String aLabel = AccountAcreageListController.FIELD_LABELS.get(theMember.fieldPath);
			if (aLabel != null)
			{
				label = aLabel;
				isPrevField = true;
			}
		}
		
		public Boolean getIsReadOnly()
		{
			return AccountAcreagesProductListController.READ_ONLY_FIELDS.contains(fieldPath);
		}
	}
}