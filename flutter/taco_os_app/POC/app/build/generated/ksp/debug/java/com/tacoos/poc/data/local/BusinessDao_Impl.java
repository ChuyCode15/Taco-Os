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
public final class BusinessDao_Impl implements BusinessDao {
  private final RoomDatabase __db;

  private final EntityInsertionAdapter<Business> __insertionAdapterOfBusiness;

  public BusinessDao_Impl(@NonNull final RoomDatabase __db) {
    this.__db = __db;
    this.__insertionAdapterOfBusiness = new EntityInsertionAdapter<Business>(__db) {
      @Override
      @NonNull
      protected String createQuery() {
        return "INSERT OR ABORT INTO `business` (`id`,`nombre`,`direccion`,`telefono`,`moneda`,`dineroBase`) VALUES (?,?,?,?,?,?)";
      }

      @Override
      protected void bind(@NonNull final SupportSQLiteStatement statement,
          @NonNull final Business entity) {
        statement.bindString(1, entity.getId());
        statement.bindString(2, entity.getNombre());
        statement.bindString(3, entity.getDireccion());
        statement.bindString(4, entity.getTelefono());
        statement.bindString(5, entity.getMoneda());
        statement.bindDouble(6, entity.getDineroBase());
      }
    };
  }

  @Override
  public Object insertBusiness(final Business business,
      final Continuation<? super Unit> $completion) {
    return CoroutinesRoom.execute(__db, true, new Callable<Unit>() {
      @Override
      @NonNull
      public Unit call() throws Exception {
        __db.beginTransaction();
        try {
          __insertionAdapterOfBusiness.insert(business);
          __db.setTransactionSuccessful();
          return Unit.INSTANCE;
        } finally {
          __db.endTransaction();
        }
      }
    }, $completion);
  }

  @Override
  public Object getBusiness(final String id, final Continuation<? super Business> $completion) {
    final String _sql = "SELECT * FROM business WHERE id = ?";
    final RoomSQLiteQuery _statement = RoomSQLiteQuery.acquire(_sql, 1);
    int _argIndex = 1;
    _statement.bindString(_argIndex, id);
    final CancellationSignal _cancellationSignal = DBUtil.createCancellationSignal();
    return CoroutinesRoom.execute(__db, false, _cancellationSignal, new Callable<Business>() {
      @Override
      @Nullable
      public Business call() throws Exception {
        final Cursor _cursor = DBUtil.query(__db, _statement, false, null);
        try {
          final int _cursorIndexOfId = CursorUtil.getColumnIndexOrThrow(_cursor, "id");
          final int _cursorIndexOfNombre = CursorUtil.getColumnIndexOrThrow(_cursor, "nombre");
          final int _cursorIndexOfDireccion = CursorUtil.getColumnIndexOrThrow(_cursor, "direccion");
          final int _cursorIndexOfTelefono = CursorUtil.getColumnIndexOrThrow(_cursor, "telefono");
          final int _cursorIndexOfMoneda = CursorUtil.getColumnIndexOrThrow(_cursor, "moneda");
          final int _cursorIndexOfDineroBase = CursorUtil.getColumnIndexOrThrow(_cursor, "dineroBase");
          final Business _result;
          if (_cursor.moveToFirst()) {
            final String _tmpId;
            _tmpId = _cursor.getString(_cursorIndexOfId);
            final String _tmpNombre;
            _tmpNombre = _cursor.getString(_cursorIndexOfNombre);
            final String _tmpDireccion;
            _tmpDireccion = _cursor.getString(_cursorIndexOfDireccion);
            final String _tmpTelefono;
            _tmpTelefono = _cursor.getString(_cursorIndexOfTelefono);
            final String _tmpMoneda;
            _tmpMoneda = _cursor.getString(_cursorIndexOfMoneda);
            final double _tmpDineroBase;
            _tmpDineroBase = _cursor.getDouble(_cursorIndexOfDineroBase);
            _result = new Business(_tmpId,_tmpNombre,_tmpDireccion,_tmpTelefono,_tmpMoneda,_tmpDineroBase);
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
