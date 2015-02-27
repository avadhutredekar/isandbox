package epam.com.newslist;

import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.Spinner;
import java.util.List;
import epam.com.newslist.loader.DynamicModelSource;
import epam.com.newslist.loader.LocaleJSONModelSource;
import epam.com.newslist.loader.ModelSource;
import epam.com.newslist.loader.ModelSourceDelegate;
import epam.com.newslist.loader.NetworkModelSource;


/**
 * Entry point
 */
public class MainActivity extends ActionBarActivity implements ModelSourceDelegate, AdapterView.OnItemSelectedListener{
    private ListView mListView;
    private ModelSource mDynamicModelSource;
    private ModelSource mLocaleJSONModelSource;
    private ModelSource mNetworkModelSource;
    private Spinner mSpinner;
    private RelativeLayout mProgressBar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mSpinner = (Spinner)findViewById(R.id.spinner_model_source);
        mListView = (ListView)findViewById(R.id.listView);
        mProgressBar = (RelativeLayout)findViewById(R.id.rel_progress);

        mDynamicModelSource = new DynamicModelSource(this);
        mLocaleJSONModelSource = new LocaleJSONModelSource(this);
        mNetworkModelSource = new NetworkModelSource(this);

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        if (toolbar != null) {
            setSupportActionBar(toolbar);
            getSupportActionBar().setDisplayShowTitleEnabled(false);
        }

        ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(toolbar.getContext(),
                R.array.model_source_types, R.layout.support_simple_spinner_dropdown_item);
        adapter.setDropDownViewResource(R.layout.support_simple_spinner_dropdown_item);
        mSpinner.setAdapter(adapter);
        mSpinner.setOnItemSelectedListener(this);
    }

    @Override
    public void finishLoadNews(ModelSource source, List<News> news) {
        mListView.setAdapter(new NewsAdapter(this, news));
        mProgressBar.setVisibility(View.INVISIBLE);
    }

    @Override
    public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
        mProgressBar.setVisibility(View.VISIBLE);
        if (position == 0) {
            mDynamicModelSource.startLoadNews(this);
        } else if (position == 1) {
            mLocaleJSONModelSource.startLoadNews(this);
        } else if (position == 2) {
            mNetworkModelSource.startLoadNews(this);
        }
    }

    @Override
    public void onNothingSelected(AdapterView<?> parent) {

    }
}
