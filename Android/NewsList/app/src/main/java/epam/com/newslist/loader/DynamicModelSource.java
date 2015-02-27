package epam.com.newslist.loader;

import android.content.Context;
import android.graphics.BitmapFactory;
import java.util.Date;
import epam.com.newslist.News;
import epam.com.newslist.R;

/**
 * Created by Anton Davydov on 2/26/15.
 * Creates the news in the run-time
 */
public class DynamicModelSource extends ModelSource {

    private final static int NEWS_COUNT = 20;

    public DynamicModelSource(Context context) {
        super(context);
    }

    @Override
    public void startLoadNews(ModelSourceDelegate delegate) {
        mNewsModel.clear();

        for (int i = 0; i < NEWS_COUNT; i++) {
            mNewsModel.add(new News(
                    new Date(),
                    String.valueOf(i + 1) + ". " +
                        ((i % 3 == 0) ?
                            context.getString(R.string.description_example_1) :
                            context.getString(R.string.description_example_2)),
                    (i % 4 == 0) ?
                            BitmapFactory.decodeResource(context.getResources(), R.drawable.dm) :
                            BitmapFactory.decodeResource(context.getResources(), R.drawable.dm_dreams)
            ));
        }

        if (delegate != null) {
            delegate.finishLoadNews(this, mNewsModel);
        }
    }
}
