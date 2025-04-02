/**
 * @description       : 
 * @author            : @BK
 * @group             : 
 * @last modified on  : 12-12-2024
 * @last modified by  : @BK
**/
public class WorkCountCompare implements Comparator<Id> {
    private Map<Id, Integer> mapOfUserIdVsCount;

    // Constructor to pass the work count map
    public WorkCountCompare(Map<Id, Integer> mapOfUserIdVsCount) {
        this.mapOfUserIdVsCount = mapOfUserIdVsCount;
    }

    // Compare method for sorting agents by their work count
    public Integer compare(Id a, Id b) {
        Integer countA = mapOfUserIdVsCount.containsKey(a) ? mapOfUserIdVsCount.get(a) : 0;
        Integer countB = mapOfUserIdVsCount.containsKey(b) ? mapOfUserIdVsCount.get(b) : 0;
        
        // Compare work counts (ascending order)
        return countA - countB;
    }
}