public virtual with sharing class FieldSetMemberxManager
{
	
	public String fieldSetName
	{
		get
		{
			if(fieldSetName == null)
			{
				fieldSetName = 'Standard';
			}
			return fieldSetName;
		} 
		set;
	}
	
	
	
	public String prefix
	{
		get; 
		set;
	}
	public String postfix
	{
		get
		{
			if(postfix == null)
			{
				return '';
			}
			else
			{
				return postfix;
			}
		}
		set;
	}
	
	public List<FieldSetMemberx>managedFieldSetMembers
	{
		get
		{
			if(managedFieldSetMembers == null)
			{
				managedFieldSetMembers = new List<FieldSetMemberx>();
				
			}
			return managedFieldSetMembers;
		} 
		set;
	}
	
	
	public Set<String>getSOQLFields()
	{
		Set<String>resultSet = new Set<String>();
		for(FieldSetMemberx m : managedFieldSetMembers)
		{
			resultSet.add(m.fieldPath);
		}
		return resultSet;
	}
	
	public FieldSetMemberxManager(Schema.DescribeSObjectResult aDescriblesObjectResult, String prefix, String fieldSetName, String postfix)
	{
		this.prefix = prefix;
		this.postfix = postfix;
		this.fieldSetName = fieldSetName.replaceAll('(\\s+)', '');
		try
		{
		this.postfix = Util.countryView.countryCode.name();
		}
		catch(Exception e)
		{
			System.debug('NO COUNTRY VIEW');
		}
		List<FieldSetMember>fieldSetMembers;
		
		//Util.addConfirmMessage(this.prefix+this.fieldSetName+this.postfix);
		
		if(aDescriblesObjectResult.fieldsets.getMap().containsKey(this.prefix+this.fieldSetName+this.postfix))
		{
			//Util.addConfirmMessage('****'+this.prefix+this.fieldSetName+this.postfix);
			//Util.addErrorMessage('****'+this.prefix+this.fieldSetName+this.postfix);
			fieldSetMembers = aDescriblesObjectResult.fieldsets.getMap().get(this.prefix+this.fieldSetName+this.postfix).getFields();
		}
		else
		{
			try
			{
			System.debug('****'+prefix+fieldSetName);
			fieldSetMembers = aDescriblesObjectResult.fieldsets.getMap().get(this.prefix+this.fieldSetName).getFields();
			}catch(Exception e){
				System.debug('TEST');}
		}
		for(FieldSetMember f : fieldSetMembers)
		{
			managedFieldSetMembers.add(createFieldSetMember(f));
		}
	}
	public FieldSetMemberxManager(Schema.DescribeSObjectResult aDescriblesObjectResult, String prefix, String postfix)
	{
		this(aDescriblesObjectResult, prefix, 'Standard', postfix);
	}
	
	public FieldSetMemberxManager(Schema.DescribeSObjectResult aDescriblesObjectResult, String prefix)
	{
		this(aDescriblesObjectResult, prefix, '');
	}
	
	protected virtual FieldSetMemberx createFieldSetMember(FieldSetMember theMember)
	{
		return new FieldSetMemberx(theMember);
	}
}