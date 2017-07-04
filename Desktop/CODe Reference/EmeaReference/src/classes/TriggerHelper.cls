/**
* Contains some useful classes and methods, that could be used in Triggers and related classes.
*/
public class TriggerHelper
{
	/**
	* General class for implementing summary fields.
	* To use it, you have to extend this class and implement performCalculation method.
	* This class will perform one SOQL request and one DML update.
	*/
	public abstract class CommonSummary
	{
		private String parentObjectName;
		private String relationName;
		protected List<String> parentFields;
		protected List<String> childFields;
		protected al.ConditionGroup parentConditions;
		protected al.ConditionGroup childConditions;
		
		protected CommonSummary(){}
		
		/**
		* Main constructor.
		* You have to set:
		* theParent - name of the parent object (that keeps summary fields).
		* theRelation - name of the relateionship from the parent to child object.
		* theParentFields - list of fields to get from parent object. They could be used in calcualtions afterwards.
		* theChildFields - list of fields to get from child object. They could be used in calcualtions afterwards.
		* theParentConditions - SOQL where conditions for Parent SOQL.
		* theParentConditions - SOQL where conditions for Child SOQL.
		*/
		public CommonSummary(String theParent, String theRelation, List<String> theParentFields, List<String> theChildFields,
				 al.ConditionGroup theParentConditions, al.ConditionGroup theChildConditions)
		{
			parentObjectName = theParent;
			relationName = theRelation;
			parentFields = theParentFields;
			if (parentFields == null)
			{
				parentFields = new List<String>{'Id'};
			}
			childFields = theChildFields;
			if (childFields == null)
			{
				childFields = new List<String>{'Id'};
			}
			parentConditions = theParentConditions;
			childConditions = theChildConditions;
		}
		
		/**
		* Constructor, that allows you to user Summary without any SOQL conditions.
		* You have to set:
		* theParent - name of the parent object (that keeps summary fields).
		* theRelation - name of the relateionship from the parent to child object.
		* theParentFields - list of fields to get from parent object. They could be used in calcualtions afterwards.
		* theChildFields - list of fields to get from child object. They could be used in calcualtions afterwards.
		*/
		public CommonSummary(String theParent, String theRelation, List<String> theParentFields, List<String> theChildFields)
		{
			this(theParent, theRelation, theParentFields, theChildFields, null, null);
		}
		
		/**
		* Method, that should be implemented to use the class.
		* This method should performa the main calculation.
		* It gets parent sObject and all the child sObjects, that are related to this parent and follows the conditions.
		* You have to return the modified parent object.
		*/
		protected abstract sObject performCalculation(sObject theParent, List<sObject> theChildList);
		
		/**
		* You should run this method to activate the main process.
		* It generates SOQL request, performs it and sends results to performCalculation method one by one.
		* Afterwards it updates modified parent objects.
		* 
		* You have to put list of IDs for parent object to update.
		*/
		public void updateObjects(Set<Id> theParentSet)
		{
			if (theParentSet == null || theParentSet.size() == 0)
			{
				return;
			}
			String aQuery = generateQuery(theParentSet);
			List<sObject> aResult = Database.query(aQuery);
			System.debug('***Result' + aResult);
			List<sObject> aListToUpdate = new List<sObject>();
			for (sObject aParent: aResult)
			{
				List<sObject> aChildren = aParent.getSObjects(relationName);
				aChildren = aChildren == null ? new List<sObject>() : aChildren;
				sObject aNewParent = performCalculation(aParent, aChildren);
				if (aNewParent != null)
				{
					aListToUpdate.add(aNewParent);
				}
			}
			update aListToUpdate;
		}
		
		/**
		* Generates query to get parent and child objects.
		*/
		private String generateQuery(Set<Id> theParentSet)
		{
			al.SoqlBuilder aSubQuery = new al.SoqlBuilder();
			aSubQuery.selectx(childFields).fromx(relationName);
			if (childConditions != null)
			{
				aSubQuery.wherex(childConditions);
			}
			String aSubString = aSubQuery.toSOQL();
			
			System.debug('*** Subquery: ' + aSubString);
			List<String> aTotalFields = new List<String>();
			aTotalFields.addAll(parentFields);
			aTotalFields.add('(' + aSubString +')');
			List<Id> aParentList = new List<Id>();
			aParentList.addAll(theParentSet);

			al.SoqlBuilder aQuery = new al.SoqlBuilder();
			al.AndCondition aConditions = new al.AndCondition();
			aConditions.add(new al.SetCondition('Id', al.Operator.INX, aParentList));
			if (parentConditions != null)
			{
				aConditions.add(parentConditions);
			}
			aQuery.selectx(aTotalFields).fromx(parentObjectName).wherex(aConditions);
			String aResSQOL = aQuery.toSOQL();
			System.debug('*** Query: ' + aResSQOL);
			return aResSQOL; 
		}
	}
	
	/**
	* Class for the simpliest summary fields, when you just need to sum up one field from child to parent.
	*/
	public virtual class SimpleSummary extends CommonSummary
	{
		/**
		* Keeps field mapping.
		*/
		protected Map<String, String> fieldMapping;
		
		/**
		* Creates a summary class and sets the mapping for parent-child field pairs.
		*/
		public SimpleSummary(String theParent, String theRelation, Map<String, String> theFieldsMap,
				   al.ConditionGroup theParentConditions, al.ConditionGroup theChildConditions)
		{
			super(theParent, theRelation, new List<String>{'Id'}, theFieldsMap.values(), theParentConditions, theChildConditions);
			fieldMapping = theFieldsMap;
		}
		
		public SimpleSummary(String theParent, String theRelation, Map<String, String> theFieldsMap)
		{
			super(theParent, theRelation, new List<String>{'Id'}, theFieldsMap.values());
			fieldMapping = theFieldsMap;
		}
		
		/**
		* It summarises child fields to parent.
		*/
		protected override sObject performCalculation(sObject theParent, List<sObject> theChildList)
		{
			for (String aParentField: fieldMapping.keySet())
			{
				Decimal aCurrentValue = 0;
				for (sObject aChild: theChildList)
				{
					Object aValue = aChild.get(fieldMapping.get(aParentField));
					aCurrentValue += aValue == null ? 0 : (Decimal) aValue;
				}
				theParent.put(aParentField, aCurrentValue);
			}
			return theParent;
		}
	}
	
	/**
	* Makes a summarizing actions from child to parent
	*/
	public static void summarizeFields(String theParent, String theRelation, Set<Id> theIds, Map<String, String> theFieldsMap, al.ConditionGroup theChildConditions)
	{
		SimpleSummary aSummary = new SimpleSummary(theParent, theRelation, theFieldsMap, null, theChildConditions);
		aSummary.updateObjects(theIds);
	}
	
	/**
	* Makes a summarizing actions from child to parent
	*/
	public static void summarizeFields(String theParent, String theRelation, Set<Id> theIds, Map<String, String> theFieldsMap)
	{
		summarizeFields(theParent, theRelation, theIds, theFieldsMap, null);
	}
}