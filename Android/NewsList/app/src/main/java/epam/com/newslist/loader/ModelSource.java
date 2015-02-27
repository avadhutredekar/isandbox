package epam.com.newslist.loader;

import android.content.Context;
import java.util.ArrayList;
import java.util.List;
import epam.com.newslist.News;

/**
 * Created by Anton Davydov on 2/26/15.
 * Base class from sources of news
 */
public abstract class ModelSource {
    protected List<News> mNewsModel = new ArrayList<News>();
    protected Context context;

    ModelSource(Context context) {
        this.context = context;
    }

    public abstract void startLoadNews(ModelSourceDelegate delegate);

    public List<News> getNews() {
        return mNewsModel;
    }
}
