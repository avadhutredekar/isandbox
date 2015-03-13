package epam.com.dropboxapi;

import android.content.Context;

import com.j256.ormlite.dao.Dao;

import java.sql.SQLException;
import java.util.List;

public class PhotosStore {

    private DatabaseHelper db;
    private Dao<Photo, Integer> photosDao;

    private static PhotosStore instance;

    public static PhotosStore getInstance(Context context) {
        instance = instance == null ? new PhotosStore(context) : instance;
        return instance;
    }

    private PhotosStore(Context ctx)
    {
        try {
            DatabaseManager dbManager = new DatabaseManager();
            db = dbManager.getHelper(ctx);
            photosDao = db.getPhotosDao();
        } catch (SQLException e) {
            // TODO: Exception Handling
            e.printStackTrace();
        }
    }

    public int create(Photo photo)
    {
        try {
            return photosDao.create(photo);
        } catch (SQLException e) {
            // TODO: Exception Handling
            e.printStackTrace();
        }
        return 0;
    }
    public int update(Photo photo)
    {
        try {
            return photosDao.update(photo);
        } catch (SQLException e) {
            // TODO: Exception Handling
            e.printStackTrace();
        }
        return 0;
    }
    public int delete(Photo photo)
    {
        try {
            return photosDao.delete(photo);
        } catch (SQLException e) {
            // TODO: Exception Handling
            e.printStackTrace();
        }
        return 0;
    }

    public List<Photo> getAllPhotos()
    {
        try {
            return photosDao.queryForAll();
        } catch (SQLException e) {
            // TODO: Exception Handling
            e.printStackTrace();
        }
        return null;
    }
}
