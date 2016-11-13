package github.epam.bigdata.module4.Model;

import java.util.Date;
import java.util.List;

/**
 * Created by dydus on 13/11/2016.
 */
public class SmartTester extends Employee {
    public List<Bug> bugs;

    SmartTester(String uuid, String name, Date birthday, Integer age, List<Bug> bugs) {
        super(uuid, name, birthday, age, JobPosition.TESTER);
        this.bugs = bugs;
    }
}