package github.epam.bigdata.module4.Model;

import java.util.Date;

/**
 * Created by dydus on 13/11/2016.
 */
public class Employee extends Comrade {
    public JobPosition jobPosition;

    public enum JobPosition {
        DEVELOPER, TESTER, MANAGER, HR
    }

    public Employee(String uuid, String name, Date birthday, Integer age, JobPosition jobPosition) {
        super(uuid, name, birthday, age);
        this.jobPosition = jobPosition;
    }
}