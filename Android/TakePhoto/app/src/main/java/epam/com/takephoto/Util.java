package epam.com.takephoto;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;

/**
 * Contains common helpful tools
 */
public class Util {

	/**
	 * Creates a photo frame for bitmap
	 * @param source
	 * @param weight
	 * @param color
	 * @return
	 */
	public static Bitmap getRoundedRectBitmap(Bitmap source, int weight, int color) {
		try {
			int w = source.getWidth();
			int h = source.getHeight();

			Bitmap output = Bitmap.createBitmap(w + weight, h + weight, Bitmap.Config.ARGB_8888);

			Paint paint = new Paint();
			paint.setAntiAlias(true);

			Canvas canvas = new Canvas(output);
			canvas.drawARGB(0, 0, 0, 0);
			paint.setStyle(Paint.Style.FILL);
			canvas.drawRect(0, 0, w + weight, h + weight, paint);

			paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));

			canvas.drawBitmap(source, weight / 2, weight / 2, paint);
			paint.setXfermode(null);
			paint.setStyle(Paint.Style.STROKE);
			paint.setColor(color);
			paint.setStrokeWidth(weight);
			canvas.drawRect(0, 0, w + weight, h + weight, paint);

			return output;
		} catch(Exception e) {
			return source;
		}
	}
}
