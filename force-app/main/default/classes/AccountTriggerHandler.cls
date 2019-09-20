/**
 *  @description Trigger handler for the Account Object
 *  @auther Jason Snyder
 *  @created 09/20/2019
 */

public without sharing class AccountTriggerHandler {
    
    /**
     * @description After Update Trigger Handler
     * @method handleAfterUpdate
     * @param oldAccountMap Map of Account Ids and old verisions of Account records
     * @param newAccountMap Map of Account Ids and new verisions of Account records
     */
    public static void handleAfterUpdate(Map<Id,Account> oldAccountMap, Map<Id,Account> newAccountMap) {
        try {
            updateOpportunityExperienceField(oldAccountMap, newAccountMap);
        }
        catch(Exception ex) {
            System.debug(ex.getMessage());
        }
    }

    /**
     * @description Updates the Experience_URL__c and Interest_Description__c fields on Opportunity
                    based on the value in Account Primary_Experience_Reference__c field
     * @method updateOpportunityExperienceField
     * @param oldAccountMap Map of Account Ids and old verisions of Account records
     * @param newAccountMap Map of Account Ids and new verisions of Account records
     */
    private static void updateOpportunityExperienceField(Map<Id,Account> oldAccountMap, Map<Id,Account> newAccountMap) {
        Map<Id,Account> changedAccountMap = getChangedAccounts(oldAccountMap, newAccountMap);
        List<Opportunity> oppList = new List<Opportunity>();
        // Get Child Opportunities
        if(changedAccountMap.size() > 0) {
            oppList = [SELECT Id, Name, AccountId, Experience_URL__c, Interest_Description__c FROM Opportunity WHERE AccountId in: changedAccountMap.keySet()];
            if(oppList.size() > 0) {
                updateOppList(oppList, changedAccountMap);
            }
        }
    }

    /**
     * @description Get a Map of account Ids and records that have the Primary_Experience_Reference__c field changed
     * @method getChangedAccounts
     * @param oldAccountMap Map of Account Ids and old verisions of Account records
     * @param newAccountMap Map of Account Ids and new verisions of Account records
     * @return Map of Account Record Ids and records that Primary_Experience_Reference__c field value has changed
     */
    private static Map<Id, Account> getChangedAccounts(Map<Id,Account> oldAccountMap, Map<Id,Account> newAccountMap) {
        Map<Id,Account> changedAccountMap = new Map<Id,Account>();

        for(Account acc : newAccountMap.values()) {
            // If Primary_Experience_Reference__c value different add to list
            if(acc.Primary_Experience_Reference__c != oldAccountMap.get(acc.Id).Primary_Experience_Reference__c) {
                changedAccountMap.put(acc.Id, acc);
            }
        }

        return changedAccountMap;
    }

    /**
     * @description Set child opportunites of accountMap accounts fields: Experience_URL__c and Interest_Description__c
                    based on Account Primary_Experience_Reference__c field LinkedIn or Trailhead
     * @method updateOppList
     * @param oppList List of child opportunites from accountMap accounts
     * @param accountMap Map of Account Record Ids and records that Primary_Experience_Reference__c field value has changed
     */
    private static void updateOppList(List<Opportunity> oppList, Map<Id, Account> accountMap) {
        for(Opportunity opp : oppList) {
            Account acc = accountMap.get(opp.AccountId);
            switch on acc.Primary_Experience_Reference__c {
                when 'LinkedIn' {
                    opp.Experience_URL__c = acc.LinkedIn_URL__c;
                    opp.Interest_Description__c = Label.Hire_on_LinkedIn;
                }
                when 'Trailhead' {
                    opp.Experience_URL__c = acc.Trailhead_URL__c;
                    opp.Interest_Description__c = Label.Hire_on_Trailhead;
                }
            }
        }

        update oppList;
    }
}
