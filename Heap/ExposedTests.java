import org.junit.jupiter.api.*;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

public class ExposedTests {

    //preparations:
    public static ArrayList<ERPriorityQueue.Patient> testPatients = new ArrayList<>();
    public static HashMap<String,Integer> testNameToIndex = new HashMap<String,Integer>();

    ERPriorityQueue testPriorityQueue = new ERPriorityQueue();

    public static <T> void  swapList(ArrayList<T> list, int i, int j){
        T temp = list.get(i);
        list.set(i,list.get(j));
        list.set(j,temp);
    }

    public static <K,V> void swapHashMapValues(HashMap<K,V> hashMap, K key1, K key2){
        V temp = hashMap.get(key1);
        hashMap.put(key1, hashMap.get(key2));
        hashMap.put(key2, temp);
    }

    public static ArrayList<ERPriorityQueue.Patient> makeDeepCopy(ArrayList<ERPriorityQueue.Patient> list) {
        ArrayList<ERPriorityQueue.Patient> copy = new ArrayList<ERPriorityQueue.Patient>();
        for (ERPriorityQueue.Patient patient : list) {
            copy.add(new ERPriorityQueue.Patient(patient.getName(), patient.getPriority()));
        }
        return copy;
    }

    public static boolean isValidHeap(ArrayList<ERPriorityQueue.Patient> list){
        for (int index = 0; index < list.size(); index++){
            if ( 2*index < list.size() && list.get(index).getPriority() > list.get(2*index).getPriority() ) {
                return false;
            }
            if ( 2*index+1 < list.size() && list.get(index).getPriority() > list.get(2*index+1).getPriority() ) {
                return false;
            }
        }
        return true;
    }

    public static boolean isValidMapping(ArrayList<ERPriorityQueue.Patient> patients, HashMap<String,Integer> nameToIndex ){
        if ( patients.size()-1 != nameToIndex.size() ) return false;
        for ( Map.Entry<String,Integer> entry : nameToIndex.entrySet()){
            String name = entry.getKey();
            int index = entry.getValue();
            if (!patients.get(index).getName().equals(name)) return false;
        }
        return true;
    }

    @BeforeAll
    public static void initialisePatientsAndHashMap() {
        testPatients.add(new ERPriorityQueue.Patient("dummy", 0.0) );
        testPatients.add(new ERPriorityQueue.Patient("Hannah",5));
        testPatients.add(new ERPriorityQueue.Patient("Ebony",10));
        testPatients.add(new ERPriorityQueue.Patient("Ahmad",15));
        testPatients.add(new ERPriorityQueue.Patient("Zil",30));
        testPatients.add(new ERPriorityQueue.Patient("Ricardo",60));
        testPatients.add(new ERPriorityQueue.Patient("Yinou",50));
        testPatients.add(new ERPriorityQueue.Patient("Gilbert",100));
        testNameToIndex.put(testPatients.get(1).getName(),1);
        testNameToIndex.put(testPatients.get(2).getName(),2);
        testNameToIndex.put(testPatients.get(3).getName(),3);
        testNameToIndex.put(testPatients.get(4).getName(),4);
        testNameToIndex.put(testPatients.get(5).getName(),5);
        testNameToIndex.put(testPatients.get(6).getName(),6);
        testNameToIndex.put(testPatients.get(7).getName(),7);
    }

    @BeforeEach
    public void resetPriorityQueue(){
        testPriorityQueue.patients = new ArrayList<>();
        // Deep copying the patients list so that we can freely mutate our test Priority queue
        for (ERPriorityQueue.Patient patient : testPatients){
            testPriorityQueue.patients.add(new ERPriorityQueue.Patient(patient));
        }
        testPriorityQueue.nameToIndex = new HashMap<>(testNameToIndex);
    }

    //upHeap tests:
    @Test
    @Tag("score:1")
    @DisplayName("upHeap Test 1")
    public void upHeapTest1(){

        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);

        // Upheaping from Patient "Hannah"
        testPriorityQueue.upHeap(1);

        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));

    }

    @Test
    @Tag("score:1")
    @DisplayName("upHeap Test 2")
    public void upHeapTest2(){

        // Setting priority of "Hannah" from 5 to 101
        testPriorityQueue.patients.get(1).setPriority(101);

        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);

        // Upheaping from Patient "Hannah"
        testPriorityQueue.upHeap(1);

        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));

    }

    @Test
    @Tag("score:2")
    @DisplayName("upHeap Test 3")
    public void upHeapTest3(){

        ERPriorityQueue.Patient karin = new ERPriorityQueue.Patient("Karin",4);

        testPriorityQueue.patients.add(karin);
        testPriorityQueue.nameToIndex.put(karin.getName(),8);

        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);

        swapList(truePatients,4,8);
        swapHashMapValues(trueNameToIndex, "Karin", "Zil");
        swapList(truePatients,2,4);
        swapHashMapValues(trueNameToIndex, "Karin", "Ebony");
        swapList(truePatients,1,2);
        swapHashMapValues(trueNameToIndex, "Karin", "Hannah");

        testPriorityQueue.upHeap(8);

        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));

    }


    @Test
    @Tag("score:2")
    @DisplayName("upHeap Test 4")
    public void upHeapTest4(){

        ERPriorityQueue.Patient karin = new ERPriorityQueue.Patient("Karin",100);
        ERPriorityQueue.Patient Loki = new ERPriorityQueue.Patient("Loki",5);

        testPriorityQueue.patients.add(karin);
        testPriorityQueue.nameToIndex.put(karin.getName(),8);
        testPriorityQueue.patients.add(Loki);
        testPriorityQueue.nameToIndex.put(Loki.getName(),9);

        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);

        swapList(truePatients,4,9);
        swapHashMapValues(trueNameToIndex, "Loki", "Zil");
        swapList(truePatients,2,4);
        swapHashMapValues(trueNameToIndex, "Loki", "Ebony");

        testPriorityQueue.upHeap(9);

        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));

    }
    // --------------------- downHeap() Unit Tests --------------------- //

    @Test
    @Tag("score:1")
    @DisplayName("downHeap Test 1")
    public void downHeapTest1(){

        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);

        // Downheaping on patient "Gilbert"
        testPriorityQueue.downHeap(7);

        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));

    }

    @Test
    @Tag("score:1")
    @DisplayName("downHeap Test 2")
    public void downHeapTest2(){

        // Setting priority of patient "Gilbert" from 100 to 1
        testPriorityQueue.patients.get(7).setPriority(1);

        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);

        // Downheaping on patient "Gilbert"
        testPriorityQueue.downHeap(7);

        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));

    }

    @Test
    @Tag("score:1")
    @DisplayName("downHeap Test 3")
    public void downHeapTest3(){

        // Setting priority of patient "Hannah" from 5 to 4
        testPriorityQueue.patients.get(1).setPriority(4);

        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);

        testPriorityQueue.downHeap(1);

        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));

    }

    @Test
    @Tag("score:1")
    @DisplayName("downHeap Test 4")
    public void downHeapTest4(){

        // Setting priority of patient "Hannah" from 5 to 15
        testPriorityQueue.patients.get(1).setPriority(15);

        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);

        swapList(truePatients,1,2);
        swapHashMapValues(trueNameToIndex, "Hannah", "Ebony");

        testPriorityQueue.downHeap(1);

        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));

    }

    @Test
    @Tag("score:2")
    @DisplayName("downHeap Test 5")
    public void downHeapTest5(){

        // Setting priority of patient "Hannah" from 5 to 31
        testPriorityQueue.patients.get(1).setPriority(31);

        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);

        swapList(truePatients,1,2);
        swapHashMapValues(trueNameToIndex, "Hannah", "Ebony");
        swapList(truePatients,2,4);
        swapHashMapValues(trueNameToIndex, "Hannah", "Zil");

        testPriorityQueue.downHeap(1);

        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));

    }

    // --------------------- contains() Unit Tests --------------------- //

    @Test
    @Tag("score:1")
    @DisplayName("contains Test 1")
    public void containsTest1(){
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);
        assertEquals(true, testPriorityQueue.contains("Hannah"));
        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));
    }

    @Test
    @Tag("score:1")
    @DisplayName("contains Test 2")
    public void containsTest2(){
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);
        assertEquals(false, testPriorityQueue.contains("Benjamin"));
        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));
    }

    @Test
    @Tag("score:1")
    @DisplayName("contains Test 3")
    public void containsTest3(){
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);
        assertEquals(true, testPriorityQueue.contains("Gilbert"));
        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));
    }

    // --------------------- getPriority() Unit Tests --------------------- //
    @Test
    @Tag("score:1")
    @DisplayName("getPriority Test 1")
    public void getPriorityTest1(){
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);
        assertEquals(5, testPriorityQueue.getPriority("Hannah"));
        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));
    }

    @Test
    @Tag("score:1")
    @DisplayName("getPriority Test 2")
    public void getPriorityTest2(){
        // Testing edge case of empty queue
        ERPriorityQueue emptyQueue = new ERPriorityQueue();
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(emptyQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(emptyQueue.nameToIndex);
        assertEquals(false, emptyQueue.contains("Hannah"));
        assertEquals(true, truePatients.equals(emptyQueue.patients));
        assertEquals(true, trueNameToIndex.equals(emptyQueue.nameToIndex));
    }

    @Test
    @Tag("score:1")
    @DisplayName("getPriority Test 3")
    public void getPriorityTest3(){
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);
        assertEquals(100, testPriorityQueue.getPriority("Gilbert"));
        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));
    }

    // --------------------- getMinPriority() Unit Tests --------------------- //
    @Test
    @Tag("score:1")
    @DisplayName("getMinPriority Test 1")
    public void getMinPriorityTest1(){
        ERPriorityQueue emptyQueue = new ERPriorityQueue();
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(emptyQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(emptyQueue.nameToIndex);
        assertEquals(-1, emptyQueue.getMinPriority());
        assertEquals(true, truePatients.equals(emptyQueue.patients));
        assertEquals(true, trueNameToIndex.equals(emptyQueue.nameToIndex));
    }

    // --------------------- removeMin() Unit Tests --------------------- //

    //@Tag("hidden")
    @Test
    @Tag("score:1")
    @DisplayName("removeMin Test 1")
    public void removeMinTest1(){
        ERPriorityQueue emptyQueue = new ERPriorityQueue();
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(emptyQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(emptyQueue.nameToIndex);
        assertNull(emptyQueue.removeMin());
        assertEquals(true, truePatients.equals(emptyQueue.patients));
        assertEquals(true, trueNameToIndex.equals(emptyQueue.nameToIndex));
    }

    @Test
    @Tag("score:2")
    @DisplayName("removeMin Test 2")
    public void removeMinTest2(){

        ERPriorityQueue queue = new ERPriorityQueue();
        ERPriorityQueue.Patient Karin = new ERPriorityQueue.Patient("Karin",10);
        queue.patients.add(Karin);
        queue.nameToIndex.put(Karin.getName(),1);

        queue.removeMin();

        ERPriorityQueue emptyQueue = new ERPriorityQueue();
        assertEquals(true, emptyQueue.patients.equals(queue.patients));
        assertEquals(true, emptyQueue.nameToIndex.equals(queue.nameToIndex));

    }

    @Test
    @Tag("score:3")
    @DisplayName("removeMin Test 3")
    public void removeMinTest3() {

        ERPriorityQueue queue = new ERPriorityQueue();
        ERPriorityQueue.Patient Rio = new ERPriorityQueue.Patient("Rio", 1);
        ERPriorityQueue.Patient Julia = new ERPriorityQueue.Patient("Julia", 2);
        ERPriorityQueue.Patient Michael = new ERPriorityQueue.Patient("Michael", 13);
        queue.patients.add(Rio);
        queue.patients.add(Julia);
        queue.patients.add(Michael);
        queue.nameToIndex.put(Rio.getName(), 1);
        queue.nameToIndex.put(Julia.getName(), 2);
        queue.nameToIndex.put(Michael.getName(), 3);

        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(queue.patients);
        HashMap<String, Integer> trueNameToIndex = new HashMap<>(queue.nameToIndex);

        // Removing Rio by removeMin()
        swapList(truePatients, 1, 3);
        swapHashMapValues(trueNameToIndex, "Rio", "Michael");
        swapList(truePatients, 1, 2);
        swapHashMapValues(trueNameToIndex, "Michael", "Julia");
        truePatients.remove(3);
        trueNameToIndex.remove("Rio");
        String minPatientName = queue.removeMin();
        assertEquals(Rio.getName(), minPatientName);
        assertEquals(truePatients, queue.patients);
        assertEquals(true, truePatients.equals(queue.patients));
        assertEquals(true, trueNameToIndex.equals(queue.nameToIndex));

        // Removing Julia by removeMin()
        swapList(truePatients, 1, 2);
        swapHashMapValues(trueNameToIndex, "Michael", "Julia");
        truePatients.remove(2);
        trueNameToIndex.remove("Julia");
        minPatientName = queue.removeMin();
        assertEquals(Julia.getName(), minPatientName);
        assertEquals(truePatients, queue.patients);
        assertEquals(true, truePatients.equals(queue.patients));
        assertEquals(true, trueNameToIndex.equals(queue.nameToIndex));

        // Removing Michael by removeMin()
        truePatients.remove(1);
        trueNameToIndex.remove("Michael");
        minPatientName = queue.removeMin();
        assertEquals(Michael.getName(), minPatientName);
        assertEquals(truePatients, queue.patients);
        assertEquals(true, truePatients.equals(queue.patients));
        assertEquals(true, trueNameToIndex.equals(queue.nameToIndex));
    }

    // --------------------- peekMin() Unit Tests --------------------- //
    @Test
    @Tag("score:1")
    @DisplayName("peekMin Test 1")
    public void peekMinTest1(){
        ERPriorityQueue emptyQueue = new ERPriorityQueue();
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(emptyQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(emptyQueue.nameToIndex);
        assertNull(emptyQueue.peekMin());
        assertEquals(true, truePatients.equals(emptyQueue.patients));
        assertEquals(true, trueNameToIndex.equals(emptyQueue.nameToIndex));
    }

    @Test
    @Tag("score:1")
    @DisplayName("peekMin Test 2")
    public void peekMinTest2(){
        ERPriorityQueue queue = new ERPriorityQueue();
        ERPriorityQueue.Patient Rio = new ERPriorityQueue.Patient("Rio",1);
        queue.patients.add(Rio);
        queue.nameToIndex.put(Rio.getName(),1);
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(queue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(queue.nameToIndex);
        assertEquals(Rio.getName(), queue.peekMin());
        assertEquals(true, truePatients.equals(queue.patients));
        assertEquals(true, trueNameToIndex.equals(queue.nameToIndex));
    }

    // --------------------- add(String,double) Unit Tests --------------------- //

    @Test
    @Tag("score:1")
    @DisplayName("add Test 1_1")
    public void addTest1_1(){
        ERPriorityQueue.Patient Hannah = testPriorityQueue.patients.get(1);

        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);

        assertEquals(false,testPriorityQueue.add(Hannah.getName(),Hannah.getPriority()));
        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));
    }

    //@Tag("hidden")
    @Test
    @Tag("score:1")
    @DisplayName("add Test 1_2")
    public void addTest1_2(){

        ERPriorityQueue queue = new ERPriorityQueue();
        ERPriorityQueue.Patient Rio = new ERPriorityQueue.Patient("Rio", 5);
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(queue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(queue.nameToIndex);
        truePatients.add(Rio);
        trueNameToIndex.put(Rio.getName(),1);

        assertEquals(true,queue.add(Rio.getName(),Rio.getPriority()));
        assertEquals(true, truePatients.equals(queue.patients));
        assertEquals(true, trueNameToIndex.equals(queue.nameToIndex));

    }

    //@Tag("hidden")
    @Test
    @Tag("score:1")
    @DisplayName("add Test 1_3")
    public void addTest1_3(){

        ERPriorityQueue queue = new ERPriorityQueue();
        ERPriorityQueue.Patient Rio = new ERPriorityQueue.Patient("Rio", 5);
        ERPriorityQueue.Patient Julia = new ERPriorityQueue.Patient("Julia", 10);
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(queue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(queue.nameToIndex);
        truePatients.add(Rio);
        truePatients.add(Julia);
        trueNameToIndex.put(Rio.getName(),1);
        trueNameToIndex.put(Julia.getName(),2);

        assertEquals(true,queue.add(Rio.getName(),Rio.getPriority()));
        assertEquals(true,queue.add(Julia.getName(),Julia.getPriority()));

        assertEquals(true, truePatients.equals(queue.patients));
        assertEquals(true, trueNameToIndex.equals(queue.nameToIndex));

    }

    //@Tag("hidden")
    @Test
    @Tag("score:1")
    @DisplayName("add Test 1_4")
    public void addTest1_4(){

        ERPriorityQueue queue = new ERPriorityQueue();
        ERPriorityQueue.Patient Rio = new ERPriorityQueue.Patient("Rio", 5);
        ERPriorityQueue.Patient Julia = new ERPriorityQueue.Patient("Julia", 10);
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(queue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(queue.nameToIndex);
        truePatients.add(Rio);
        truePatients.add(Julia);
        trueNameToIndex.put(Rio.getName(),1);
        trueNameToIndex.put(Julia.getName(),2);

        // Here we add Julia then Rio instead
        assertEquals(true,queue.add(Julia.getName(),Julia.getPriority()));
        assertEquals(true,queue.add(Rio.getName(),Rio.getPriority()));

        assertEquals(true, truePatients.equals(queue.patients));
        assertEquals(true, trueNameToIndex.equals(queue.nameToIndex));

    }

    @Test
    @Tag("score:2")
    @DisplayName("add Test 1_5")
    public void addTest1_5(){

        ERPriorityQueue.Patient Rio = new ERPriorityQueue.Patient("Rio",9);

        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);

        truePatients.add(Rio);
        trueNameToIndex.put(Rio.getName(),8);
        swapList(truePatients,4,8);
        swapHashMapValues(trueNameToIndex, "Rio", "Zil");
        swapList(truePatients,2,4);
        swapHashMapValues(trueNameToIndex, "Rio", "Ebony");

        assertEquals(true,testPriorityQueue.add(Rio.getName(),Rio.getPriority()));

        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));

    }

    // --------------------- add(String) Unit Tests --------------------- //
    @Test
    @Tag("score:1")
    @DisplayName("add Test 2_1")
    public void addTest2_1(){

        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);

        assertEquals(false, testPriorityQueue.add("Hannah"));
        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));
    }

    @Test
    @Tag("score:1")
    @DisplayName("add Test 2_2")
    public void addTest2_2(){

        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);

        truePatients.add(new ERPriorityQueue.Patient("Pete", Double.POSITIVE_INFINITY));
        trueNameToIndex.put("Pete",8);

        assertEquals(true, testPriorityQueue.add("Pete"));
        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));
    }

    @Test
    @Tag("score:1")
    @DisplayName("add Test 2_3")
    public void addTest2_3(){
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);

        ERPriorityQueue.Patient Jack = new ERPriorityQueue.Patient("Jack", Double.POSITIVE_INFINITY);

        truePatients.add(Jack);
        trueNameToIndex.put(Jack.getName(),8);

        assertEquals(true, testPriorityQueue.add("Jack"));
        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));
    }

    // --------------------- remove() Unit Tests --------------------- //
    @Test
    @Tag("score:1")
    @DisplayName("remove Test 1")
    public void removeTest1() {
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);

        assertEquals(false, testPriorityQueue.remove("Elliot"));
        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));
    }

    @Test
    @Tag("score:1")
    @DisplayName("remove Test 2")
    public void removeTest2() {
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);

        ERPriorityQueue.Patient Gilbert = truePatients.remove(7);
        trueNameToIndex.remove(Gilbert.getName(), 7);

        assertEquals(true, testPriorityQueue.remove("Gilbert"));
        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));
    }

    @Test
    @Tag("score:2")
    @DisplayName("remove Test 3")
    public void removeTest3() {
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);

        swapList(truePatients,1,7);
        swapHashMapValues(trueNameToIndex, "Hannah", "Gilbert");
        ERPriorityQueue.Patient Hannah = truePatients.remove(7);
        trueNameToIndex.remove("Hannah");
        swapList(truePatients,1,2);
        swapHashMapValues(trueNameToIndex, "Gilbert", "Ebony");
        swapList(truePatients,2,4);
        swapHashMapValues(trueNameToIndex, "Gilbert", "Zil");

        assertEquals(true, testPriorityQueue.remove("Hannah"));
        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));
    }

    @Test
    @Tag("score:2")
    @DisplayName("remove Test 4")
    public void removeTest4() {
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);

        swapList(truePatients,3,7);
        swapHashMapValues(trueNameToIndex, "Ahmad", "Gilbert");
        ERPriorityQueue.Patient Ahmad = truePatients.remove(7);
        trueNameToIndex.remove("Ahmad");
        swapList(truePatients,3,6);
        swapHashMapValues(trueNameToIndex, "Gilbert", "Yinou");

        assertEquals(true, testPriorityQueue.remove("Ahmad"));
        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));
    }

    // --------------------- changePriority() Unit Tests --------------------- //
    @Test
    @Tag("score:2")
    @DisplayName("changePriority Test 1")
    public void changePriorityTest1() {
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);
        truePatients.get(7).setPriority(90);

        assertEquals(true, testPriorityQueue.changePriority("Gilbert", 90));
        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));
    }

    //@Tag("hidden")
    @Test
    @Tag("score:2")
    @DisplayName("changePriority Test 2")
    public void changePriorityTest2() {
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);
        truePatients.get(1).setPriority(40);

        swapList(truePatients,1,2);
        swapHashMapValues(trueNameToIndex, "Hannah", "Ebony");

        swapList(truePatients,2,4);
        swapHashMapValues(trueNameToIndex, "Hannah", "Zil");

        assertEquals(true, testPriorityQueue.changePriority("Hannah", 40));
        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));
    }

    //@Tag("hidden")
    @Test
    @Tag("score:2")
    @DisplayName("changePriority Test 3")
    public void changePriorityTest3() {
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);
        truePatients.get(3).setPriority(1);

        swapList(truePatients,1,3);
        swapHashMapValues(trueNameToIndex, "Hannah", "Ahmad");

        assertEquals(true, testPriorityQueue.changePriority("Ahmad", 1));
        assertEquals(true, truePatients.equals(testPriorityQueue.patients));
        assertEquals(true, trueNameToIndex.equals(testPriorityQueue.nameToIndex));
    }

    // --------------------- removeUrgentPatients() Unit Tests --------------------- //
    @Test
    @Tag("score:2")
    @DisplayName("removeUrgentPatients Test 1")
    public void removeUrgentPatientsTest1() {
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);
        HashMap<String,Integer> trueNameToIndex = new HashMap<>(testPriorityQueue.nameToIndex);

        ArrayList<ERPriorityQueue.Patient> urgentList = testPriorityQueue.removeUrgentPatients(1);

        assertEquals(0, urgentList.size());
        assertEquals(true, isValidHeap(testPriorityQueue.patients));
        assertEquals(true, isValidMapping(testPriorityQueue.patients, testPriorityQueue.nameToIndex));
        assertEquals(true, truePatients.containsAll(testPriorityQueue.patients) && truePatients.size() == testPriorityQueue.patients.size());
    }
    @Test
    @Tag("score:3")
    @DisplayName("removeUrgentPatients Test 2")
    public void removeUrgentPatientsTest2() {
        ERPriorityQueue.Patient Gilbert = testPriorityQueue.patients.get(7);

        ERPriorityQueue trueQueue = new ERPriorityQueue();
        trueQueue.patients.add(new ERPriorityQueue.Patient(Gilbert.getName(), Gilbert.getPriority()));
        trueQueue.nameToIndex.put(Gilbert.getName(),1);

        ArrayList<ERPriorityQueue.Patient> trueUrgentList = makeDeepCopy(testPriorityQueue.patients);
        // Removing Gilbert
        trueUrgentList.remove(7);
        // Removing dummy
        trueUrgentList.remove(0);

        ArrayList<ERPriorityQueue.Patient> urgentList = testPriorityQueue.removeUrgentPatients(60);

        assertEquals(trueQueue.patients, testPriorityQueue.patients);
        assertEquals(trueQueue.nameToIndex, testPriorityQueue.nameToIndex);

        assertEquals(true, trueUrgentList.containsAll(urgentList) && trueUrgentList.size() == urgentList.size());
    }

    // --------------------- removeNonUrgentPatients() Unit Tests --------------------- //
    @Test
    @Tag("score:2")
    @DisplayName("removeNonUrgentPatients Test 1")
    public void removeNonUrgentPatientsTest1() {
        ArrayList<ERPriorityQueue.Patient> truePatients = makeDeepCopy(testPriorityQueue.patients);

        ArrayList<ERPriorityQueue.Patient> nonUrgentList = testPriorityQueue.removeNonUrgentPatients(200);

        assertEquals(0, nonUrgentList.size());
        assertEquals(true, isValidHeap(testPriorityQueue.patients));
        assertEquals(true, isValidMapping(testPriorityQueue.patients, testPriorityQueue.nameToIndex));
        assertEquals(true, truePatients.containsAll(testPriorityQueue.patients) && truePatients.size() == testPriorityQueue.patients.size());
    }

    //@Tag("hidden")
    @Test
    @Tag("score:2")
    @DisplayName("removeNonUrgentPatients Test 2")
    public void removeNonUrgentPatientsTest2() {
        ArrayList<ERPriorityQueue.Patient> trueUrgentList = makeDeepCopy(testPriorityQueue.patients);

        ERPriorityQueue emptyQueue = new ERPriorityQueue();

        ArrayList<ERPriorityQueue.Patient> urgentList = testPriorityQueue.removeNonUrgentPatients(1);

        // Removing dummy
        trueUrgentList.remove(0);

        assertEquals(true, trueUrgentList.containsAll(urgentList) && trueUrgentList.size() == urgentList.size());
        assertEquals(emptyQueue.patients, testPriorityQueue.patients);
        assertEquals(emptyQueue.nameToIndex, testPriorityQueue.nameToIndex);
    }

    //@Tag("hidden")
    @Test
    @Tag("score:3")
    @DisplayName("removeNonUrgentPatients Test 3")
    public void removeNonUrgentPatientsTest3() {
        ERPriorityQueue.Patient Ricardo = testPriorityQueue.patients.get(5);
        ERPriorityQueue.Patient Gilbert = testPriorityQueue.patients.get(7);

        ArrayList<ERPriorityQueue.Patient> trueNonUrgentList = new ArrayList();
        trueNonUrgentList.add(new ERPriorityQueue.Patient(Ricardo.getName(), Ricardo.getPriority()));
        trueNonUrgentList.add(new ERPriorityQueue.Patient(Gilbert.getName(), Gilbert.getPriority()));

        ArrayList<ERPriorityQueue.Patient> trueUrgentList = makeDeepCopy(testPriorityQueue.patients);

        // Removing Gilbert
        trueUrgentList.remove(7);
        // Removing Ricardo
        trueUrgentList.remove(5);

        ArrayList<ERPriorityQueue.Patient> nonUrgentList = testPriorityQueue.removeNonUrgentPatients(60);

        assertEquals(true, isValidHeap(testPriorityQueue.patients));
        assertEquals(true, isValidMapping(testPriorityQueue.patients, testPriorityQueue.nameToIndex));
        assertEquals(true, trueUrgentList.containsAll(testPriorityQueue.patients) && trueUrgentList.size() == testPriorityQueue.patients.size());
        assertEquals(true, trueNonUrgentList.containsAll(nonUrgentList) && trueNonUrgentList.size() == nonUrgentList.size());
    }
    public static void main(String[] args){
        ExposedTests test=new ExposedTests();
        test.addTest1_1();
    }

}
