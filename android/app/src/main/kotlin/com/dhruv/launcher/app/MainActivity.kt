
package com.dhruv.launcher.app

import android.content.Intent
import android.provider.Settings
import com.facebook.FacebookSdk
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val LAUNCHER_CHANNEL =
        "com.dhruv.launcher.app/launcher"

    private val FACEBOOK_CHANNEL =
        "com.dhruv.launcher.app/facebook"

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        // --------------------------------
        // LAUNCHER METHOD CHANNEL
        // --------------------------------

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            LAUNCHER_CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "isDefaultLauncher" -> {
                    result.success(isDefaultLauncher())
                }

                "openLauncherChooser" -> {
                    try {
                        openLauncherChooserSettings()
                        result.success(null)
                    } catch (e: Exception) {
                        result.error(
                            "ERROR",
                            e.message,
                            null
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }

        // --------------------------------
        // FACEBOOK METHOD CHANNEL
        // --------------------------------

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            FACEBOOK_CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "setFacebookCredentials" -> {

                    try {

                        val appId =
                            call.argument<String>("appId")

                        val clientToken =
                            call.argument<String>("clientToken")

                        if (appId.isNullOrBlank() ||
                            clientToken.isNullOrBlank()
                        ) {
                            result.error(
                                "INVALID_CONFIG",
                                "Facebook App ID or Client Token is empty",
                                null
                            )
                            return@setMethodCallHandler
                        }

                        // Prevent changing credentials after initialization
                        if (FacebookSdk.isInitialized()) {

                            if (FacebookSdk.getApplicationId() != appId) {
                                result.error(
                                    "ALREADY_INITIALIZED",
                                    "Facebook SDK already initialized with another App ID",
                                    null
                                )
                                return@setMethodCallHandler
                            }

                            result.success(true)
                            return@setMethodCallHandler
                        }

                        // STEP 1: Set dynamic App ID
                        FacebookSdk.setApplicationId(appId)

                        // STEP 2: Set dynamic Client Token
                        FacebookSdk.setClientToken(clientToken)

                        // STEP 3: Initialize base Facebook SDK
                        // AutoInitEnabled must be false in Manifest.
                        @Suppress("DEPRECATION")
                        FacebookSdk.sdkInitialize(applicationContext)

                        // Verify native initialization
                        if (!FacebookSdk.isInitialized()) {
                            result.error(
                                "INIT_FAILED",
                                "Facebook SDK initialization failed",
                                null
                            )
                            return@setMethodCallHandler
                        }

                        // STEP 4: Return success to Flutter
                        result.success(true)

                    } catch (e: Exception) {

                        result.error(
                            "FACEBOOK_ERROR",
                            e.message ?: "Facebook initialization error",
                            null
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    // --------------------------------
    // CHECK DEFAULT LAUNCHER
    // --------------------------------

    private fun isDefaultLauncher(): Boolean {

        val intent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
        }

        val resolveInfo = packageManager.resolveActivity(
            intent,
            android.content.pm.PackageManager.MATCH_DEFAULT_ONLY
        )

        val currentHomePackage =
            resolveInfo?.activityInfo?.packageName ?: return false

        return currentHomePackage == packageName
    }

    // --------------------------------
    // OPEN LAUNCHER SETTINGS
    // --------------------------------

    private fun openLauncherChooserSettings() {

        try {
            startActivity(
                Intent(Settings.ACTION_HOME_SETTINGS)
            )

        } catch (e: Exception) {

            startActivity(
                Intent(Settings.ACTION_SETTINGS)
            )
        }
    }
}
