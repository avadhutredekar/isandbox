package github.epam.bigdata.module4;

import com.mongodb.MongoClient;
import com.mongodb.client.MongoDatabase;

/**
 * Created by dydus on 09/11/2016.
 */
public class MongoDriverMain {

    public static void main(String[] args) {
        MongoClient mc = new MongoClient("localhost", 27017);
        MongoDatabase db = mc.getDatabase("collections");

        Utils.fillDB(db);

        System.out.println("Name of the oldest developer: " + Utils.getOldestDeveloper(db).name);
        System.out.println("Name of the youngest student: " + Utils.getYoungestStudent(db).name);

        Utils.randomizeStudentRatings(db);
        System.out.println("Added ratings for students");

        Utils.findBugsForSmartTester(db);
        System.out.println("Added bugs for the smartest tester");

        Utils.increaseRatings(db);

        Utils.resolveBugs(db);

        Utils.hideBigDataSpec(db);

        Utils.createIndexes(db);

        mc.close();
    }
}














