package epam.com.newslist.loader;

import java.util.List;

import epam.com.newslist.News;

/**
 * Created by Anton Davydov on 2/26/15.
 * Delegate the finish of task for source of news
 */
public interface ModelSourceDelegate {

    void finishLoadNews(ModelSource source, List<News> news);

}
