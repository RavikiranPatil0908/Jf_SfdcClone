global class Leadsquare 
{
    
     @InvocableMethod(label='Sync Lead with Lead Square' description='Inserts/Update the Lead data with Lead Square from Process builder.')
public static void LeadIdtoUpdate(List<Id> leads) {
      
     /* String leadQueryString = getQueryAllFieldSql('Lead',' id=:leads',null);
        List<Lead> lstLead = DataBase.query(leadQueryString);
        System.debug('lstLead.size()--->'+lstLead.size());
        if(lstLead.size() > 0 )
        {
            Lead objlead = new Lead (id=lstLead[0].id);           
            calloutmethod(objlead.id);
        }*/
        if(System.IsBatch() == false && System.isFuture() == false){
        
            calloutmethod(leads[0]);
        }
  }
  @future (callout=true)
  public static void calloutmethod(String LeadId){
      
     leadSquaredConfigWebservice.updateLeadInLeadsquare(LeadId);
  }
   public static String getQueryAllFieldSql(String SObjectAPIName,String conditionString,String relatedFields){
        Map < String, schema.SObjectType > scemapMap = schema.getGlobalDescribe();
        Map < String, schema.SObjectField > fieldMap = scemapMap.get(SObjectAPIName).getDescribe().fields.getMap();
        List <String> fieldNames = new List <String> (fieldMap.keySet());
        if(relatedFields !=null && relatedFields !=''){
            fieldNames.add(relatedFields);
        }
        String query = 'Select '+String.join( fieldNames, ',') +' from '+ SObjectAPIName +' where '+conditionString;
        
        return query;
    }
     
}