public without sharing class JSONHelper{
    
    public List<Map<String,String>> lstAttr{get;set;}
    
    public JSONHelper(){
        
        lstAttr=new List<Map<String,String>>();
    }
    
    public void addLeadAttribute (String attributeName, String valueOfAttribute)
    {
        Map<String,String> field = new Map<String,String>();
        field.put('Attribute', attributeName);
        field.put('Value', valueOfAttribute);
        lstAttr.add(field);
    }
   
    public String getJSONString()
    {
       if (lstAttr == null){
          return '{}';
       }else{
            String str=JSON.serialize(lstAttr);
            System.debug('str-->'+str);
            return str;
        }
    } 
}