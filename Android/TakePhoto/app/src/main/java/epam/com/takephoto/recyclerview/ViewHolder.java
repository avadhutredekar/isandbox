package epam.com.takephoto.recyclerview;

/**
 * Created by Anton Davydov on 3/12/15.
 */

import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.widget.ImageView;

import epam.com.takephoto.R;

/**
 * An item for RecyclerView
 */
class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
	protected ImageView photo;
	protected MyClickListener listener;
	public String path;

	public ViewHolder(View view) {
		super(view);
		this.photo = (ImageView) view.findViewById(R.id.imageView_photo);
		this.photo.setOnClickListener(this);
	}

	public void setMyClickListener(MyClickListener listener) {
		this.listener = listener;
	}

	@Override
	public void onClick(View v) {
		if (listener != null)
			listener.onClick(this);
	}
}

/**
 * Called when user taps recyclerview item
 */
interface MyClickListener {
	public void onClick(ViewHolder v);
}