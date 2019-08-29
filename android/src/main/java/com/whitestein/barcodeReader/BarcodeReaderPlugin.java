package com.whitestein.barcodeReader;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.support.annotation.NonNull;
import android.support.v4.app.FragmentManager;
import android.support.v4.content.ContextCompat;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import com.budiyev.android.codescanner.CodeScanner;
import com.budiyev.android.codescanner.CodeScannerView;
import com.budiyev.android.codescanner.DecodeCallback;
import com.getcapacitor.BridgeActivity;
import com.getcapacitor.JSObject;
import com.getcapacitor.NativePlugin;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.whitestein.capacitorbarcodereader.R;
import com.google.zxing.Result;

enum BarcodeReaderError {
    AccessDenied
}

@NativePlugin(permissions = {Manifest.permission.CAMERA}, permissionRequestCode = BarcodeReaderPlugin.RequestCodes.Camera)
public class BarcodeReaderPlugin extends Plugin {
    public static String CLOSE_EVENT = "close-barcode-reader";

    private CodeScanner mCodeScanner;

    @PluginMethod()
    public void open(PluginCall call) {
        try {
            close();
            if (ContextCompat.checkSelfPermission(getActivity(), Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED) {
                Intent intent = new Intent(getActivity(), BarcodeReaderActivity.class);
                startActivityForResult(call, intent, RequestCodes.Camera);
            } else {
                call.error(BarcodeReaderError.AccessDenied.toString());
            }
        }
        catch(Exception ex) {
            call.error("ERROR", ex);
        }
    }

    @Override
    protected void handleOnActivityResult(int requestCode, int resultCode, Intent data) {
        super.handleOnActivityResult(requestCode, resultCode, data);
        PluginCall savedCall = getSavedCall();

        if (savedCall == null) {
            return;
        }
        if (requestCode == RequestCodes.Camera) {
            JSObject ret = new JSObject();
            if (data == null) {
                ret.put("action", "closed");
            } else {
                ret.put("action", "found");
                ret.put("value", data.getStringExtra("code"));
            }
            savedCall.resolve(ret);
            return;
        }
        savedCall.reject("Plugin error");
    }


    @PluginMethod()
    public void close(PluginCall call) {
        close();
        JSObject ret = new JSObject();
        ret.put("action", "closed");
        call.resolve(ret);
    }
    private void close() {
        Intent intent = new Intent(CLOSE_EVENT);
        LocalBroadcastManager.getInstance(getActivity()).sendBroadcast(intent);
    }
    public interface RequestCodes {
        int Camera = 10001;
    }
}

