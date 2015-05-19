package dydus.com.multicloudservice;

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

import java.util.List;


class GalleryRecyclerAdapter extends RecyclerView.Adapter<ViewHolder> implements ViewHolder.MyClickListener, StorageProvider.ProviderCallBack {
	private Cursor mGalleryCursor;
	private Context mContext;

	GalleryRecyclerAdapter(final Context context) {
		mContext = context;
		StorageProvider.getInstance().listener = this;
		StorageProvider.getInstance().queryPaths();
		updateGallery();
	}

	public void updateGallery() {
		close();
		String[] projection = new String[]{ MediaStore.MediaColumns.DATA };
		mGalleryCursor = mContext.getContentResolver().query(
				MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
				projection, null, null,
				null);
		this.notifyDataSetChanged();
	}



	public void close() {
		if (mGalleryCursor != null && !mGalleryCursor.isClosed()) {
			mGalleryCursor.close();
		}
	}


	@Override
	public ViewHolder onCreateViewHolder(ViewGroup viewGroup, int i) {
		View v = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.recycler_item, viewGroup, false);
		ViewHolder mh = new ViewHolder(v);
		return mh;
	}

	@Override
	public void onBindViewHolder(ViewHolder currentItem, int i) {

		if (mGalleryCursor != null && i < mGalleryCursor.getCount()) {
			mGalleryCursor.moveToPosition(i);
			String path = mGalleryCursor
					.getString(mGalleryCursor.getColumnIndex(MediaStore.MediaColumns.DATA));

			Picasso.with(mContext)
					.load("file://" + path)
					.fit()
					.centerCrop()
							//.placeholder(R.drawable.abc_cab_background_top_material)
					.into(currentItem.photo);

			currentItem.setMyClickListener(this);
			currentItem.path = path;
		}

		currentItem.state = StorageProvider.getInstance().getState(currentItem);
		setPhotoState(currentItem);
	}


	@Override
	public int getItemCount() {
		int count = 0;
		if (mGalleryCursor != null && !mGalleryCursor.isClosed()) {
			count += mGalleryCursor.getCount();
		}

		return count;
	}

	@Override
	public void onClick(ViewHolder v) {
		if (mContext != null && v.path != null) {
			Intent intent = new Intent();
			intent.setAction(android.content.Intent.ACTION_VIEW);
			intent.setDataAndType(Uri.parse("file://" + v.path),"image/*");
			mContext.startActivity(intent);
		}
	}

	private void setPhotoState(ViewHolder holder) {
		int icon;
		if (holder.state == ViewHolder.State.SYNC_APP) {
			icon = R.drawable.load_up_icon;
		} else if (holder.state == ViewHolder.State.SYNC_SERVICE) {
			icon = R.drawable.load_down_icon;
		} else {
			icon = R.drawable.complite_icon;
		}

		Picasso.with(mContext)
				.load(icon)
				.fit()
				.centerCrop()
				.into(holder.icon);
	}

	@Override
	public void updateData() {
		updateGallery();
	}
}