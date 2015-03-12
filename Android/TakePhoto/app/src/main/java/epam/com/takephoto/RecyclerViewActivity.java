package epam.com.takephoto;

import android.database.Cursor;
import android.graphics.BitmapFactory;
import android.provider.MediaStore;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;


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
        mRecyclerView.setAdapter(new MyRecyclerAdapter());
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        onBackPressed();
        return true;
    }

    private class MyRecyclerAdapter extends RecyclerView.Adapter<ViewHolder> {

        @Override
        public ViewHolder onCreateViewHolder(ViewGroup viewGroup, int i) {
            View v = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.recycler_item, viewGroup, false);
            ViewHolder mh = new ViewHolder(v);
            return mh;
        }

        @Override
        public void onBindViewHolder(ViewHolder currentItem, int i) {
            mGalleryCursor.moveToPosition(i);

            String data = mGalleryCursor
                    .getString(mGalleryCursor.getColumnIndex(MediaStore.MediaColumns.DATA));
			currentItem.photo.setImageBitmap(BitmapFactory.decodeFile(data));
        }

        @Override
        public int getItemCount() {
            return mGalleryCursor.getCount();
        }
    }

	/**
	 * An item for RecyclerView
	 */
    private class ViewHolder extends RecyclerView.ViewHolder {
        protected ImageView photo;

        public ViewHolder(View view) {
            super(view);
            this.photo = (ImageView) view.findViewById(R.id.imageView_photo);
        }
    }
}