package io.lozzax.coin

import java.nio.ByteBuffer

import android.app.Activity
import android.os.Looper
import android.os.Handler

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.*
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar


class LozzaxCoinPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel : MethodChannel

    companion object {
        // val lozzaxApi = LozzaxApi()
        val main = Handler(Looper.getMainLooper())

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "lozzax_coin")
            channel.setMethodCallHandler(LozzaxCoinPlugin())
        }
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "lozzax_coin")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        // lozzaxApi.load()
    }
}
