package github.epam.bigdata.module4.Model;

import java.util.Date;

/**
 * Created by dydus on 13/11/2016.
 */
public class Comrade {
    public String uuid;
    public String name;
    public Date birthday;
    public Integer age;

    public Comrade(String uuid, String name, Date birthday, Integer age) {
        this.uuid = uuid;
        this.name = name;
        this.birthday = birthday;
        this.age = age;
    }
}
