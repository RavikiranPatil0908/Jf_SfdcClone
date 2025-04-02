public with sharing class NetCoreStudentBatchScheduler implements Schedulable {
    public void execute(SchedulableContext sc){
        Database.executeBatch(new BatchClassPushAccountToNetCore(), 200);
    }
}