package github.epam.bigdata.module4;

import com.mongodb.client.FindIterable;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.UpdateOptions;
import github.epam.bigdata.module4.Model.*;
import github.epam.bigdata.module4.Model.Employee.JobPosition;
import org.bson.Document;
import org.bson.conversions.Bson;
import org.bson.types.ObjectId;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Random;
import java.util.stream.Collectors;

import static com.mongodb.client.model.Filters.*;
import static java.lang.Math.abs;

/**
 * Created by dydus on 13/11/2016.
 */
public class Utils {
    public static void fillDB(MongoDatabase db) {
        db.drop();

        MongoCollection employeesCollection = db.getCollection("Employees");
        MongoCollection studentsCollection = db.getCollection("Students");

        List<Document> employees = new ArrayList<Document>();
        employees.add(DBAdapter.getDocumentFromEmployee(new Employee("E#1", "E#1.name", new Date(), 22, JobPosition.DEVELOPER)));
        employees.add(DBAdapter.getDocumentFromEmployee(new Employee("E#2", "E#2.name", new Date(), 24, JobPosition.HR)));
        employees.add(DBAdapter.getDocumentFromEmployee(new Employee("E#3", "E#3.name", null, null, JobPosition.MANAGER)));
        employees.add(DBAdapter.getDocumentFromEmployee(new Employee("E#4", "E#4.name", null, null, JobPosition.TESTER)));
        employees.add(DBAdapter.getDocumentFromEmployee(new Employee("E#5", "E#5.name", null, null, JobPosition.DEVELOPER)));
        employees.add(DBAdapter.getDocumentFromEmployee(new Employee("E#6", "E#6.name", new Date(), 35, JobPosition.TESTER)));
        employees.add(DBAdapter.getDocumentFromEmployee(new Employee("E#7", "E#7.name", new Date(), 20, JobPosition.DEVELOPER)));
        employees.add(DBAdapter.getDocumentFromEmployee(new Employee("E#8", "E#8.name", new Date(), 30, JobPosition.MANAGER)));
        employees.add(DBAdapter.getDocumentFromEmployee(new Employee("E#9", "E#9.name", new Date(), 40, JobPosition.HR)));
        employees.add(DBAdapter.getDocumentFromEmployee(new Employee("E#10", "E#10.name", new Date(), 25, JobPosition.DEVELOPER)));

        employeesCollection.insertMany(employees);

        List<Document> students = new ArrayList<Document>();
        students.add(DBAdapter.getDocumentFromStudent(new Student("S#1", "S#1.name", new Date(), 18, null, null, "ITMO", 1)));
        students.add(DBAdapter.getDocumentFromStudent(new Student("S#2", "S#2.name", new Date(), 18, null, "EPAM", "LETI", 1)));
        students.add(DBAdapter.getDocumentFromStudent(new Student("S#3", "S#3.name", null, null, null, null, "ITMO", 4)));
        students.add(DBAdapter.getDocumentFromStudent(new Student("S#4", "S#4.name", new Date(), 30, null, "EPAM", "LETI", 2)));
        students.add(DBAdapter.getDocumentFromStudent(new Student("S#5", "S#5.name", new Date(), 21, null, null, "LETI", 4)));
        students.add(DBAdapter.getDocumentFromStudent(new Student("S#6", "S#6.name", new Date(), 17, null, "JetBrains", "LETI", 1)));
        students.add(DBAdapter.getDocumentFromStudent(new Student("S#7", "S#7.name", new Date(), 20, null, "Luxsoft", "ITMO", 2)));
        students.add(DBAdapter.getDocumentFromStudent(new Student("S#8", "S#8.name", new Date(), 20, null, null, "LETI", 2)));
        students.add(DBAdapter.getDocumentFromStudent(new Student("S#9", "S#9.name", null, null, null, null, "LETI", 3)));
        students.add(DBAdapter.getDocumentFromStudent(new Student("S#10", "S#10.name", new Date(), 23, null, "EPAM", "LETI", 5)));

        studentsCollection.insertMany(students);
    }

    public static Employee getOldestDeveloper(MongoDatabase db) {
        Document result = db
                .getCollection("Employees")
                .find()
                .filter(and(eq("position", "DEVELOPER"), not(eq("age", null))))
                .sort(new Document("age", -1))
                .limit(1)
                .first();
        return DBAdapter.getEmployeeFromDocument(result);
    }

    public static Student getYoungestStudent(MongoDatabase db) {
        Document result = db
                .getCollection("Students")
                .find()
                .filter(not(eq("age", null)))
                .sort(new Document("age", 1))
                .limit(1)
                .first();
        return DBAdapter.getStudentFromDocument(result);
    }

    public static void randomizeStudentRatings(MongoDatabase db) {
        MongoCollection collection = db.getCollection("Students");
        FindIterable<Document> iter = collection.find();
        for (Document item : iter) {

            Document update = new Document("$set", new Document()
                            .append("ratings", randomizeRating()
                                    .stream()
                                    .map((i)->DBAdapter.getDocumentFromRating(i))
                                    .collect(Collectors.toList())));

            collection.updateOne(
                    eq("_id", item.get("_id")),
                    update, new UpdateOptions().upsert(true));
        }
    }

    public static void findBugsForSmartTester(MongoDatabase db) {
        // The smartest means the oldest
        MongoCollection collection = db.getCollection("Employees");
        Document result = (Document) collection
                .find()
                .filter(and(eq("position", "TESTER"), not(eq("age", null))))
                .sort(new Document("age", -1))
                .limit(1)
                .first();

        Document update = new Document("$set", new Document()
                .append("bugs", randomizeBugs()
                        .stream()
                        .map((i)->DBAdapter.getDocumentFromBug(i))
                        .collect(Collectors.toList())));

        collection.updateOne(
                eq("_id", result.get("_id")),
                update, new UpdateOptions().upsert(true));
    }

    public static void increaseRatings(MongoDatabase db) {
        Random rand = new Random();
        MongoCollection collection = db.getCollection("Students");
        FindIterable<Document> iter = collection.find();
        for (Document item : iter) {
            String studyPlace = item.getString("studyPlace");

            // Define ability to increase rating
            int percentOfIncreasing = 0;

            if (item.getString("studyPlace").equals("LETI"))
                percentOfIncreasing += 40;
            else
                percentOfIncreasing += 10;


            if (item.getString("jobPlace") == null)
                percentOfIncreasing += 30;
            else if (item.getString("jobPlace").equals("EPAM"))
                percentOfIncreasing += 20;
            else
                percentOfIncreasing += 10;

            percentOfIncreasing += 5*item.getInteger("course");
            final int finalPercentOfIncreasing = percentOfIncreasing;
            List<Document> ratings = (List<Document>)item.get("ratings");
            List<Document> newRatings = ratings.stream().map((i) ->
                    finalPercentOfIncreasing < abs(rand.nextInt()) % 100 ?
                            i :
                            i.append("value", i.getInteger("value")+1)
            ).collect(Collectors.toList());

            System.out.println("Student "+item.getString("name")+" percent of increasing " + percentOfIncreasing);
            System.out.println("Old rating: " + ratings);
            System.out.println("New rating: " + newRatings);

            Document update = new Document("$set", new Document().append("ratings", newRatings));

            collection.updateOne(
                    eq("_id", item.get("_id")),
                    update, new UpdateOptions().upsert(true));
        }
    }

    private static List<Rating> randomizeRating() {
        List<Rating> result = new ArrayList<>();
        Random rand = new Random();
        int amountOfItems = abs(rand.nextInt()) % 7 + 1;
        for (int i = 0; i < amountOfItems; i++) {
            result.add(new Rating("Course"+(i+1), abs(rand.nextInt())%10+1));
        }
        return result;
    }

    private static List<Bug> randomizeBugs() {
        List<Bug> result = new ArrayList<>();
        Random rand = new Random();
        int amountOfItems = abs(rand.nextInt()) % 10 + 1;
        for (int i = 0; i < amountOfItems; i++) {
            result.add(new Bug("BugTitle"+(i+1), abs(rand.nextInt())%4+1));
        }
        return result;
    }
}
