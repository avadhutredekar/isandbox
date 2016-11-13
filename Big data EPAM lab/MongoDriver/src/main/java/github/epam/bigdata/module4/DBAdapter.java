package github.epam.bigdata.module4;

import com.mongodb.client.FindIterable;
import com.mongodb.client.MongoCollection;
import github.epam.bigdata.module4.Model.*;
import github.epam.bigdata.module4.Model.Employee.JobPosition;
import org.bson.Document;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Created by dydus on 13/11/2016.
 */
public class DBAdapter {

    public static Document getDocumentFromComrade(Comrade comrade) {
        return new Document()
                .append("uuid", comrade.uuid)
                .append("name", comrade.name)
                .append("birthday", comrade.birthday)
                .append("age", comrade.age);
    }

    public static Document getDocumentFromEmployee(Employee employee) {
        return DBAdapter.getDocumentFromComrade(employee)
                .append("position", employee.jobPosition.toString());
    }

    public static Document getDocumentFromTester(SmartTester tester) {
        Document result = DBAdapter.getDocumentFromEmployee(tester);
        if (tester.bugs != null)
            result.append("bugs", tester.bugs
                        .stream()
                        .map((item)->DBAdapter.getDocumentFromBug(item))
                        .collect(Collectors.toList()));

        return result;
    }

    public static Document getDocumentFromStudent(Student student) {
        Document result = DBAdapter.getDocumentFromComrade(student);
        if (student.ratings != null)
            result.append("ratings", student.ratings
                .stream()
                .map( (item) -> DBAdapter.getDocumentFromRating(item))
                .collect(Collectors.toList()));

        return result
                .append("jobPlace", student.jobPlace)
                .append("studyPlace", student.studyPlace)
                .append("course", student.course);
    }

    public static Document getDocumentFromRating(Rating rating) {
        return new Document()
                .append("name", rating.name)
                .append("value", rating.value);
    }

    public static Document getDocumentFromBug(Bug bug) {
        return new Document()
                .append("title", bug.title)
                .append("priority", bug.priority);
    }


    public static Employee getEmployeeFromDocument(Document document) {
        return new Employee(document.getString("uuid"),
                            document.getString("name"),
                            document.getDate("birthday"),
                            document.getInteger("age"),
                            JobPosition.valueOf(document.getString("position"))
                );
    }

    public static Student getStudentFromDocument(Document document) {
        return new Student(document.getString("uuid"),
                            document.getString("name"),
                            document.getDate("birthday"),
                            document.getInteger("age"),
                            null,
                            document.getString("jobPlace"),
                            document.getString("studyPlace"),
                            document.getInteger("course")
                );
    }

    public static void setComradeList(List<Comrade> list, MongoCollection dbCollection) {
        List result = list.stream().map( (item) ->

                 new Document()
                        .append("uuid", item.uuid)
                        .append("name", item.name)
                        .append("birthday", item.birthday)
                        .append("age", item.age)
        ).collect(Collectors.toList());

        dbCollection.insertMany(result);
    }

    public static List<Comrade> getComradeList(MongoCollection dbCollection) {
        List<Comrade> result = new ArrayList<Comrade>();
        FindIterable<Document> iter = dbCollection.find();
        for (Document item : iter) {
            result.add(
                    new Comrade(item.getString("uuid"), item.getString("name"), item.getDate("birthday"), item.getInteger("age"))
            );
        }
        return result;
    }


}