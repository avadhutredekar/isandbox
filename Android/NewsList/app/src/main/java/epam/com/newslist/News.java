package epam.com.newslist;

import android.graphics.Bitmap;
import java.util.Date;

/**
 * Created by Anton Davydov on 2/25/15.
 */
public class News {
    public Bitmap bitmap;
    public String description;
    public Date time;

    public News() {}
    public News(Date time, String description, Bitmap bitmap) {
        this.time = time;
        this.description = description;
        this.bitmap = bitmap;
    }
}
