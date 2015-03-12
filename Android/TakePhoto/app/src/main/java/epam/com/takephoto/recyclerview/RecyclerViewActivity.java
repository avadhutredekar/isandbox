package epam.com.takephoto.recyclerview;

import android.database.Cursor;
import android.provider.MediaStore;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.MenuItem;

import epam.com.takephoto.R;


public class RecyclerViewActivity extends ActionBarActivity {

	private static final int COUNT_ITEMS_IN_LINE = 3;

    private RecyclerView mRecyclerView;
    private Cursor mGalleryCursor;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_recycler_view);
        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        String[] projection = new String[]{ MediaStore.MediaColumns.DATA };
        mGalleryCursor = getContentResolver().query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                projection, null, null,
                null);

        mRecyclerView = (RecyclerView) findViewById(R.id.recycler_view);
		GridLayoutManager glm = new GridLayoutManager(this, COUNT_ITEMS_IN_LINE);
		mRecyclerView.setLayoutManager(glm);
        mRecyclerView.setAdapter(new MyRecyclerAdapter(this, mGalleryCursor));
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        onBackPressed();
        return true;
    }
}