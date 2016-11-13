package github.epam.bigdata.module4.Model;

import java.util.Date;
import java.util.List;

/**
 * Created by dydus on 13/11/2016.
 */
public class Student extends Comrade {
    public List<Rating> ratings;
    public String jobPlace;
    public String studyPlace;
    public Integer course;

    public Student(String uuid, String name, Date birthday, Integer age, List<Rating> ratings, String jobPlace, String studyPlace, Integer course) {
        super(uuid, name, birthday, age);
        this.ratings = ratings;
        this.jobPlace = jobPlace;
        this.studyPlace = studyPlace;
        this.course = course;
    }
}