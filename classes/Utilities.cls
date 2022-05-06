
public without sharing class Utilities {    

    //Used to slice an array in Apex. Implementation by sfdcfox: https://salesforce.stackexchange.com/questions/179786/apex-array-slice
    public static Availability__c[] avSlice(Availability__c[] ary, Integer first, Integer last) {
        Availability__c[] res = ary.clone(), temp;
        Integer size = ary.size(),
            startIndex = Math.min(size, Math.max(-1, first<0? size+first: first)),
            endIndex = Math.min(size, Math.max(-1, last<0? size+last: last-1)),
            offset = Math.max(-1, endIndex-startIndex);
        temp = new Availability__c[offset+1];
        for(Integer h = 0, i = startIndex, j = endIndex; i <= j; ) {
            temp[h++] = ary[i++];
        }
        res.clear();
        res.addAll(temp);
        return res;
    }
}
