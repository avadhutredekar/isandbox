package epam.com.dropboxapi;

import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.widget.TabHost;


public class MainActivity extends ActionBarActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
        if (toolbar != null) {

            setSupportActionBar(toolbar);
            getSupportActionBar().setDisplayShowHomeEnabled(true);
            getSupportActionBar().setIcon(R.drawable.toolbar_icon);
        }

        TabHost tabHost = (TabHost)findViewById(R.id.tabhost);
        tabHost.setup();

        tabHost.addTab(tabHost.newTabSpec("tag1").setIndicator(getString(R.string.tab1_title)).setContent(R.id.tab1));
        tabHost.addTab(tabHost.newTabSpec("tag2").setIndicator(getString(R.string.tab2_title)).setContent(R.id.tab2));

        if (findViewById(R.id.tab3) != null) {
            tabHost.addTab(tabHost.newTabSpec("tag3").setIndicator(getString(R.string.tab3_title)).setContent(R.id.tab3));
        }
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        int id = item.getItemId();

        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }
}
