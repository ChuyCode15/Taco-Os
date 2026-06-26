package com.tacoos.poc.data.local;

import android.database.Cursor;
import android.os.CancellationSignal;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.room.CoroutinesRoom;
import androidx.room.EntityInsertionAdapter;
import androidx.room.RoomDatabase;
import androidx.room.RoomSQLiteQuery;
import androidx.room.util.CursorUtil;
import androidx.room.util.DBUtil;
import androidx.sqlite.db.SupportSQLiteStatement;
import java.lang.Class;
import java.lang.Exception;
import java.lang.Object;
import java.lang.Override;
import java.lang.String;
import java.lang.SuppressWarnings;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.Callable;
import javax.annotation.processing.Generated;
import kotlin.Unit;
import kotlin.coroutines.Continuation;

@Generated("androidx.room.RoomProcessor")
@SuppressWarnings({"unchecked", "deprecation"})
public final class MetadataDao_Impl implements MetadataDao {
  private final RoomDatabase __db;

  private final EntityInsertionAdapter<AppMetadata> __insertionAdapterOfAppMetadata;

  public MetadataDao_Impl(@NonNull final RoomDatabase __db) {
    this.__db = __db;
    this.__insertionAdapterOfAppMetadata = new EntityInsertionAdapter<AppMetadata>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "INSERT OR REPLACE INTO `app_metadata` (`id`,`lastLoginTimestamp`,`lastMasterSyncTimestamp`,`isLicenseValid`) VALUES (?,?,?,?)";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final AppMetadata entity) {
        statement.bindLong(1, entity.getId());
        statement.bindLong(2, entity.getLastLoginTimestamp());
        statement.bindLong(3, entity.getLastMasterSyncTimestamp());
        final int _tmp = entity.isLicenseValid() ? 1 : 0;
        statement.bindLong(4, _tmp);
      }
    };
  }

  @Override
  public Object updateMetadata(final AppMetadata metadata,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __insertionAdapterOfAppMetadata.insert(metadata);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object getMetadata(final Continuation<? super AppMetadata> $completion) {
    final String _sql = "SELECT * FROM app_metadata WHERE id = 1";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 0);
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<AppMetadata>() {
      @Override
      @Nullable
      public AppMetadata call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfLastLoginTimestamp = CursorUtil.getColumnIndexOrThrow(_cursor, "lastLoginTimestamp");
          final int _cursorIndexOfLastMasterSyncTimestamp = CursorUtil.getColumnIndexOrThrow(_cursor, "lastMasterSyncTimestamp");
          final int _cursorIndexOfIsLicenseValid = CursorUtil.getColumnIndexOrThrow(_cursor, "isLicenseValid");
          final AppMetadata _result;
          if (_cursor.moveToFirst()) {
            final int _tmpId;
            _tmpId = _cursor.getInt(_cursorIndexOfId);
            final long _tmpLastLoginTimestamp;
            _tmpLastLoginTimestamp = _cursor.getLong(_cursorIndexOfLastLoginTimestamp);
            final long _tmpLastMasterSyncTimestamp;
            _tmpLastMasterSyncTimestamp = _cursor.getLong(_cursorIndexOfLastMasterSyncTimestamp);
            final boolean _tmpIsLicenseValid;
            final int _tmp;
            _tmp = _cursor.getInt(_cursorIndexOfIsLicenseValid);
            _tmpIsLicenseValid = _tmp != 0;
            _result = new AppMetadata(_tmpId,_tmpLastLoginTimestamp,_tmpLastMasterSyncTimestamp,_tmpIsLicenseValid);
          } else {
            _result = null;
          }
          return _result;
        } finally {
          _cursor.close();
          _statement.release();
        }
      }
    }, $completion);
  }

  @NonNull
  public static List<Class<?>> getRequiredConverters() {
    return Collections.emptyList();
  }
}
