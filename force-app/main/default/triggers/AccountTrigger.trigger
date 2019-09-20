/**
 *  @description Account Trigger
 *  @auther Jason Snyder
 *  @created 09/20/2019
 */

trigger AccountTrigger on Account (after update) {

    // After Update
    if(Trigger.isUpdate && Trigger.isAfter) {
        AccountTriggerHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
    }
}