package dydus.com.multicloudservice;

import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.widget.ImageView;


class ViewHolder extends RecyclerView.ViewHolder implements View.OnClickListener {
	protected ImageView photo;
	protected ImageView icon;
	protected MyClickListener listener;
	public State state;
	public String path;

	public ViewHolder(View view) {
		super(view);
		this.photo = (ImageView) view.findViewById(R.id.imageView_photo);
		this.icon = (ImageView) view.findViewById(R.id.image_state);
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

	 public interface MyClickListener {
		public void onClick(ViewHolder v);
	}

	public enum State {
		SYNC_BOTH, SYNC_APP, SYNC_SERVICE
	}
}