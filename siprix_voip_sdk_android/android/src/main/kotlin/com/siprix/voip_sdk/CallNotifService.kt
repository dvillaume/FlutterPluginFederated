@file:Suppress("SpellCheckingInspection")
package com.siprix.voip_sdk

import android.Manifest
import android.annotation.SuppressLint
import android.app.ActivityManager
import android.app.ActivityManager.RunningAppProcessInfo
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.os.Binder
import android.os.Build
import android.os.Build.VERSION
import android.os.Bundle
import android.os.IBinder
import android.os.PowerManager
import android.os.PowerManager.WakeLock
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.siprix.ISiprixRinger
import com.siprix.ISiprixServiceListener
import com.siprix.SiprixCore
import com.siprix.SiprixRinger


class CallNotifService : Service(), ISiprixServiceListener {
    private var _ringer: ISiprixRinger? = null
    private var _wakeLock: WakeLock? = null
    private val _binder: IBinder = LocalBinder()
    private var _foregroundModeStarted: Boolean = false
    
    private var _appContentLabel: String = "Incoming call"
    private var _appRejectBtnLabel: String = "Reject call"
    private var _appAcceptBtnLabel: String = "Accept call"
    private var _appNameLabel: String = "AppName"
    private var _appIconId: Int = 0
    private var _requestCode: Int = 1

    inner class LocalBinder : Binder() {
        val service: CallNotifService
            get() =// Return this instance of LocalService so clients can call public methods.
                this@CallNotifService
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "onCreate")
        _ringer = SiprixRinger(this)
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "onDestroy")
        stopForegroundMode()
        notifMgr.cancelAll()

        _ringer = null

        if(core != null) {
            core?.setServiceListener(null)
            core?.setModelListener(null)
            core?.unInitialize()
            core = null
        }
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        Log.d(TAG, "onTaskRemoved")
        super.onTaskRemoved(rootIntent)
    }

    override fun onBind(intent: Intent): IBinder? {
        return _binder
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "onStartCommand $intent")
        val result = super.onStartCommand(intent, flags, startId)

        if(intent != null) {
            if (kActionIncomingCallReject == intent.action) {
                handleIncomingCallIntent(intent)
            }

            if(kActionAppStarted == intent.action) {
                core?.setServiceListener(this)
                getLabelsFromResources()
                createNotifChannel()
            }

            if(kActionIncomingCallStopRinger == intent.action) {
                _ringer?.stop()
            }
        }
        return result
    }

    private fun createNotifChannel() {
        if (VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            //NotificationChannel msgChannel = new NotificationChannel(kMsgChannelId,
            //        appName, NotificationManager.IMPORTANCE_DEFAULT);
            //msgChannel.enableLights(true);
            //notifMgr_.createNotificationChannel(msgChannel);

            val callChannel = NotificationChannel(
                kCallChannelId, _appNameLabel, NotificationManager.IMPORTANCE_HIGH
            )
            callChannel.lockscreenVisibility= Notification.VISIBILITY_PUBLIC
            callChannel.description = "Incoming calls notifications channel" //TODO resource
            //callChannel.enableLights(true);
            notifMgr.createNotificationChannel(callChannel)
        }
    }

    private fun getIntentActivity(action: String?, bundle: Bundle): PendingIntent {
        val activityIntent = packageManager.getLaunchIntentForPackage(this.packageName)
        if(activityIntent==null) {
            Log.e(TAG, "Can't get launch intent!")
        }
        activityIntent?.action = action

        activityIntent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        activityIntent?.putExtras(bundle)
        return PendingIntent.getActivity(
            this, _requestCode++, activityIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun getIntentService(action: String?, bundle: Bundle): PendingIntent {
        val srvIntent = Intent(action)
        srvIntent.setClassName(this, CallNotifService::class.java.name)
        srvIntent.putExtras(bundle)
        return PendingIntent.getService(
            this, _requestCode++, srvIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    fun handleIncomingCallIntent(intent: Intent) {
        val args = intent.extras
        val callId = args?.getInt(kExtraCallId) ?: 0
        if (callId <= 0) return
        //if (kActionIncomingCallAccept == intent.action) {
        //    core!!.callAccept(callId, false) //TODO add 'withVideo'
        //} else
        if (kActionIncomingCallReject == intent.action) {
            core!!.callReject(callId)
        }
        cancelNotification(callId)
    }

    private fun cancelNotification(callId: Int) {
        notifMgr.cancel(kCallBaseNotifId + callId)
    }

    private val notifMgr: NotificationManager
        get() = getSystemService(NOTIFICATION_SERVICE) as NotificationManager

    private fun displayIncomingCallNotification(
        callId: Int, accId: Int,
        withVideo: Boolean, hdrFrom: String?, hdrTo: String?
    ) {
        Log.d(TAG, "displayIncomingCallNotification $callId")
        val bundle = Bundle()
        bundle.putInt(kExtraCallId, callId)
        bundle.putInt(kExtraAccId, accId)
        bundle.putBoolean(kExtraWithVideo, withVideo)
        bundle.putString(kExtraHdrFrom, hdrFrom)
        bundle.putString(kExtraHdrTo, hdrTo)

        val contentIntent = getIntentActivity(kActionIncomingCall, bundle)
        val pendingAcceptCall = getIntentActivity(kActionIncomingCallAccept, bundle)
        val pendingRejectCall = getIntentService(kActionIncomingCallReject, bundle)

        //Popup style
        val bigTextStyle = NotificationCompat.BigTextStyle()
        bigTextStyle.bigText(hdrFrom)
        bigTextStyle.setBigContentTitle(_appContentLabel)

        val builder: NotificationCompat.Builder = NotificationCompat.Builder(this, kCallChannelId)
            .setSmallIcon(_appIconId)
            .setContentTitle(_appContentLabel)
            .setContentText(hdrFrom)
            .setAutoCancel(true)
            .setChannelId(kCallChannelId)
            .setDefaults(Notification.DEFAULT_ALL)
            .setContentIntent(contentIntent)
            .setFullScreenIntent(contentIntent, true)
            .setOngoing(true)
            .setStyle(bigTextStyle)
            .addAction(0, _appRejectBtnLabel, pendingRejectCall)
            .addAction(0, _appAcceptBtnLabel, pendingAcceptCall)
            .setDeleteIntent(getIntentService(kActionIncomingCallStopRinger, bundle))
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setPriority(NotificationCompat.PRIORITY_HIGH)

        if (VERSION.SDK_INT >= 21)
            builder.setColor(-0x80ff01)

        notifMgr.notify(kCallBaseNotifId + callId, builder.build())
    }

    fun stopForegroundMode() {
        releaseWakelock()
        if (VERSION.SDK_INT >= 33){
            stopForeground(STOP_FOREGROUND_REMOVE)
        }else {
            @Suppress("DEPRECATION")
            stopForeground(true)
        }
        _foregroundModeStarted = false
    }

    fun startForegroundMode(): Boolean {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.FOREGROUND_SERVICE)
            != PackageManager.PERMISSION_GRANTED) return false

        acquireWakelock()

        val contentIntent = getIntentActivity(kActionForeground, Bundle())
        val builder: Notification.Builder = if (VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, kCallChannelId)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        builder.setSmallIcon(_appIconId)
            .setContentTitle(_appNameLabel)
            .setContentText("Siprix call notification service")
            .setContentIntent(contentIntent)
            .build() // getNotification()

        if (VERSION.SDK_INT >= 29) {
            startForeground(kForegroundId, builder.build(),
                ServiceInfo.FOREGROUND_SERVICE_TYPE_PHONE_CALL
            )
        } else {
            startForeground(kForegroundId, builder.build())
        }
        _foregroundModeStarted = true
        return true
    }

    fun isForegroundMode() :Boolean {
        return _foregroundModeStarted
    }

    private fun acquireWakelock() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.WAKE_LOCK)
            != PackageManager.PERMISSION_GRANTED) return

        if (_wakeLock == null) {
            val powerManager = getSystemService(POWER_SERVICE) as PowerManager
            _wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "Siprix:WakeLock.")
        }
        if (_wakeLock != null && !_wakeLock!!.isHeld) {
            _wakeLock!!.acquire()
        }
    }

    private fun releaseWakelock() {
        if (_wakeLock != null && _wakeLock!!.isHeld) {
            _wakeLock!!.release()
        }
    }

    override fun onRingerState(start: Boolean) {
        if (start) _ringer?.start() else _ringer?.stop()
    }

    override fun onCallTerminated(callId: Int, statusCode: Int) {
        cancelNotification(callId)
    }

    override fun onCallIncoming(
        callId: Int, accId: Int, withVideo: Boolean,
        hdrFrom: String, hdrTo: String
    ) {
        Log.i(TAG, "onCallIncoming "+callId)
        if (!isAppInForeground) {
            displayIncomingCallNotification(callId, accId, withVideo, hdrFrom, hdrTo)
        }
    }

    private fun getLabelsFromResources() {
        val content = getStrResource(kResourceContentLabel)
        if (content != null) _appContentLabel = content //"Incoming call"

        val reject = getStrResource(kResourceRejectBtnLabel)
        if (reject != null) _appRejectBtnLabel = reject //"Reject call"

        val accept = getStrResource(kResourceAcceptBtnLabel)
        if (accept != null) _appAcceptBtnLabel = accept //"Accept call"

        val name = getStrResource("app_name")
        _appNameLabel = name ?: applicationInfo.nonLocalizedLabel.toString()

        _appIconId = getMipmapResource("ic_launcher")
    }

    @SuppressLint("DiscouragedApi")
    private fun getStrResource(resName: String): String? {
        val stringRes = resources.getIdentifier(resName, "string", packageName)
        return if(stringRes != 0) getString(stringRes) else null
    }

    @SuppressLint("DiscouragedApi")
    private fun getMipmapResource(resName: String): Int {
        return resources.getIdentifier(resName, "mipmap", packageName)
    }

    private val isAppInForeground: Boolean
        get() {
            val am = this.getSystemService(ACTIVITY_SERVICE) as ActivityManager
            val appProcs = am.runningAppProcesses
            for (app in appProcs) {
                if (app.importance == RunningAppProcessInfo.IMPORTANCE_FOREGROUND) {
                    val found = listOf(*app.pkgList).contains(packageName)
                    if (found) return true
                }
            }
            return false
        }

    companion object {
        private const val TAG = "CallNotifService"
        const val kCallChannelId = "kSiprixCallChannelId_"
        //const val kMsgChannelId = "kSiprixMsgChannelId"

        const val kActionAppStarted = "kActionAppStarted"
        const val kActionForeground = "kActionForeground"
        
        const val kActionIncomingCall = "kActionIncomingCall"
        const val kActionIncomingCallAccept = "kActionIncomingCallAccept"
        const val kActionIncomingCallReject = "kActionIncomingCallReject"
        const val kActionIncomingCallStopRinger = "kActionIncomingCallStopRinger"

        const val kExtraCallId   = "kExtraCallId"
        const val kExtraAccId    = "kExtraAccId"
        const val kExtraWithVideo= "kExtraWithVideo"
        const val kExtraHdrFrom  = "kExtraHdrFrom"
        const val kExtraHdrTo    = "kExtraHdrTo"

        const val kResourceRejectBtnLabel = "reject_btn_label"
        const val kResourceAcceptBtnLabel = "accept_btn_label"
        const val kResourceContentLabel = "content_label"

        const val kCallBaseNotifId = 555
        const val kForegroundId = 777

        //Single instance, provides access to calling functionality
        private var core: SiprixCore? = null

        fun createSiprixCore(appContext : Context): SiprixCore {
            if(core == null) {
                core = SiprixCore(appContext)
            }
            return core!!
        }
    }
}
