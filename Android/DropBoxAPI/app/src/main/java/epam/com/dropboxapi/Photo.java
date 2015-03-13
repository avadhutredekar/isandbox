package epam.com.dropboxapi;

import java.util.Date;
import com.j256.ormlite.field.DataType;
import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;

/**
 * Created by Anton Davydov on 3/2/15.
 */
@DatabaseTable(tableName = "photos")
public class Photo {

    @DatabaseField(generatedId = true)
    public int id = -1;

    @DatabaseField()
    public String fileName;

    @DatabaseField(dataType = DataType.DATE)
    public Date date;

    @DatabaseField()
    public String localePath;

    @DatabaseField()
    public String remotePath;

    public Photo() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getFileName() {
        return fileName;
    }
    public void setFileName(String fileName) {
        this.fileName = fileName;
    }
    public Date getDate() {
        return date;
    }
    public void setDate(Date date) {
        this.date = date;
    }
    public String getLocalePath() {
        return localePath;
    }
    public void setLocalePath(String localePath) {
        this.localePath = localePath;
    }
    public String getRemotePath() {
        return remotePath;
    }
    public void setRemotePath(String remotePath) {
        this.remotePath = remotePath;
    }
}
