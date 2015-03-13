package epam.com.takephoto.recyclerview;

import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.provider.MediaStore;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.squareup.picasso.Picasso;

import epam.com.takephoto.R;

/**
 * Created by Anton Davydov on 3/12/15.
 */
class MyRecyclerAdapter extends RecyclerView.Adapter<ViewHolder> implements MyClickListener {
	private Cursor mGalleryCursor;
	private Context mContext;
	private int mSpanCount;
	private int mItemSquareSize;

	MyRecyclerAdapter(Context context, Cursor cursor, int spanCount) {
		mGalleryCursor = cursor;
		mContext = context;
		this.mSpanCount = spanCount;

	}

	@Override
	public ViewHolder onCreateViewHolder(ViewGroup viewGroup, int i) {
		View v = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.recycler_item, viewGroup, false);
		ViewHolder mh = new ViewHolder(v);
		mItemSquareSize = viewGroup.getWidth()/ mSpanCount;
		return mh;
	}

	@Override
	public void onBindViewHolder(ViewHolder currentItem, int i) {
		mGalleryCursor.moveToPosition(i);
		String path = "file://" + mGalleryCursor
				.getString(mGalleryCursor.getColumnIndex(MediaStore.MediaColumns.DATA));

		Picasso.with(mContext).load(path).resize(mItemSquareSize, mItemSquareSize)
				.centerCrop().placeholder(R.drawable.ic_launcher).into(currentItem.photo);
		currentItem.setMyClickListener(this);
		currentItem.path = path;
	}

	@Override
	public int getItemCount() {
		return mGalleryCursor.getCount();
	}

	@Override
	public void onClick(ViewHolder v) {
		if (mContext != null && v.path != null) {
			Intent intent = new Intent();
			intent.setAction(android.content.Intent.ACTION_VIEW);
			intent.setDataAndType(Uri.parse(v.path),"image/*");
			mContext.startActivity(intent);
		}
	}
}