public without sharing class OpportunityLineItemDataTableController {
    @AuraEnabled(cacheable=true)
    public static List<OpportunityLineItem> getOpportunityLineItems(Id opportunityId) {
        return [SELECT Id, Product2.Name, UnitPrice, Quantity, ActualSalePrice__c, TotalPrice, ServiceDate, Description FROM OpportunityLineItem WHERE OpportunityId = :opportunityId];
    }
}