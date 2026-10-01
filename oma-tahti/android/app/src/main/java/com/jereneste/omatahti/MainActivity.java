package com.jereneste.omatahti;
import android.app.Activity;
import android.os.Bundle;
import android.net.Uri;
import android.content.Intent;
import android.webkit.*;
import android.widget.Toast;
import org.json.JSONTokener;
import androidx.webkit.WebViewAssetLoader;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;

public final class MainActivity extends Activity {
    private WebView web;
    private String pendingExport;
    private static final String ORIGIN = "https://appassets.androidplatform.net/assets/web/";
    @Override public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (savedInstanceState != null) pendingExport = savedInstanceState.getString("pendingExport");
        web = new WebView(this); setContentView(web);
        web.setOnApplyWindowInsetsListener((v, insets) -> {
            if (android.os.Build.VERSION.SDK_INT >= 30) {
                android.graphics.Insets bars = insets.getInsets(android.view.WindowInsets.Type.systemBars() | android.view.WindowInsets.Type.ime());
                v.setPadding(bars.left, bars.top, bars.right, bars.bottom);
            } else { v.setPadding(insets.getSystemWindowInsetLeft(), insets.getSystemWindowInsetTop(), insets.getSystemWindowInsetRight(), insets.getSystemWindowInsetBottom()); }
            return insets;
        });
        WebSettings s = web.getSettings(); s.setJavaScriptEnabled(true); s.setDomStorageEnabled(true);
        s.setAllowFileAccess(false); s.setAllowContentAccess(false); s.setMixedContentMode(WebSettings.MIXED_CONTENT_NEVER_ALLOW);
        WebViewAssetLoader loader = new WebViewAssetLoader.Builder().addPathHandler("/assets/", new WebViewAssetLoader.AssetsPathHandler(this)).build();
        web.setWebViewClient(new WebViewClient() {
            @Override public WebResourceResponse shouldInterceptRequest(WebView v, WebResourceRequest r) {
                WebResourceResponse local = loader.shouldInterceptRequest(r.getUrl());
                if (local != null) return local;
                return new WebResourceResponse("text/plain", "UTF-8", new java.io.ByteArrayInputStream(new byte[0]));
            }
            @Override public boolean shouldOverrideUrlLoading(WebView v, WebResourceRequest r) {
                String u = r.getUrl().toString(); if (u.startsWith(ORIGIN)) return false;
                String scheme = r.getUrl().getScheme();
                if ("https".equals(scheme) || "tel".equals(scheme) || "mailto".equals(scheme)) {
                    try { startActivity(new Intent(Intent.ACTION_VIEW, r.getUrl())); } catch (Exception e) { notifyUser("Linkin avaamiseen ei löydy sovellusta."); }
                }
                return true;
            }
        });
        web.setWebChromeClient(new WebChromeClient());
        web.addJavascriptInterface(new Object() {
            @JavascriptInterface public void exportData() { runOnUiThread(() -> beginExport()); }
        }, "OmaTahtiNative");
        if (savedInstanceState == null || web.restoreState(savedInstanceState) == null) web.loadUrl(ORIGIN + "index.html");
    }
    private void notifyUser(String text) { Toast.makeText(this, text, Toast.LENGTH_LONG).show(); }
    private void beginExport() {
        if (web.getUrl() == null || !web.getUrl().startsWith(ORIGIN)) return;
        web.evaluateJavascript("JSON.stringify(state, null, 2)", value -> {
            try {
                Object decoded = new JSONTokener(value).nextValue();
                if (!(decoded instanceof String)) { notifyUser("Tietojen vienti ei onnistunut."); return; }
                pendingExport = (String) decoded;
                Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT).addCategory(Intent.CATEGORY_OPENABLE).setType("application/json").putExtra(Intent.EXTRA_TITLE, "oma-tahti-merkinnat.json");
                startActivityForResult(intent, 1);
            } catch (Exception e) { notifyUser("Tietojen vienti ei onnistunut."); }
        });
    }
    @Override protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode != 1) return;
        if (resultCode == RESULT_OK && data != null && data.getData() != null && pendingExport != null) {
            try (OutputStream out = getContentResolver().openOutputStream(data.getData())) {
                if (out == null) throw new java.io.IOException();
                out.write(pendingExport.getBytes(StandardCharsets.UTF_8)); notifyUser("Merkinnät tallennettu.");
            } catch (Exception e) { notifyUser("Tallennus ei onnistunut."); }
        }
        pendingExport = null;
    }
    @Override protected void onSaveInstanceState(Bundle out) { super.onSaveInstanceState(out); web.saveState(out); out.putString("pendingExport", pendingExport); }
    @Override public void onBackPressed() { if (web.canGoBack()) web.goBack(); else super.onBackPressed(); }
    @Override protected void onDestroy() { web.removeJavascriptInterface("OmaTahtiNative"); web.destroy(); super.onDestroy(); }
}
