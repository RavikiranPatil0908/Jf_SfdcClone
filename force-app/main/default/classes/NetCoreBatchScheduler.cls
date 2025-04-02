public class NetCoreBatchScheduler implements Schedulable {

    public void execute(SchedulableContext sc){
        Database.executeBatch(new BatchClassPushLeadToNetCore(), 200);
    }
    
}