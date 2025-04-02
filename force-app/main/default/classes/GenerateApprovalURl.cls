public with sharing class GenerateApprovalURl {
    public String ObjId;
    public String urlStr {get; set;} 
    public GenerateApprovalURl() {
        system.debug('ASASS');
    }
    public String getObjId() {
		return this.ObjId;
	}

	public void setObjId(String ObjId) {
        System.debug('ObjId');
        System.debug(ObjId);
        this.ObjId = ObjId;
        if(ObjId != null){
            System.debug('ObjId');
             generateApprovalURLString();
          
        }
	}

    public void generateApprovalURLString() {
        String url='';  
        system.debug('gfhfghfgh');
  
        List<ProcessInstanceWorkitem> workItemLst =   
        [  SELECT id  FROM ProcessInstanceWorkitem  
            WHERE processInstance.TargetObjectId=:ObjId];   

        if(workItemLst.size() > 0)  {  

            url='https://'+ System.URL.getSalesforceBaseUrl().getHost() +   
            '/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + workItemLst[0].id;     

            urlStr = url;
            System.debug(urlStr);

        }
    }

}