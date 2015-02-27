package epam.com.newslist;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Locale;

/**
 * Created by Anton Davydov on 2/25/15.
 */
public class NewsAdapter extends ArrayAdapter<News> {
    private static DateFormat df = DateFormat.getDateInstance(DateFormat.MEDIUM, Locale.getDefault());
    private static SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy", Locale.getDefault());

    public NewsAdapter(Context context, List<News> objects) {
        super(context, R.layout.news_item, objects);
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View result = convertView;
        News modelItem = getItem(position);

        if (result == null) {
            result = LayoutInflater.from(getContext()).inflate(R.layout.news_item, null);
        }

        ImageView bitmap = (ImageView) result.findViewById(R.id.imageView_bitmap);
        TextView description = (TextView) result.findViewById(R.id.textView_description);
        TextView time = (TextView) result.findViewById(R.id.textView_time);

        bitmap.setImageBitmap(modelItem.bitmap);
        description.setText(modelItem.description);

        if (modelItem.time != null) {
            time.setText(sdf.format(modelItem.time));
        }

        return result;
    }
}
