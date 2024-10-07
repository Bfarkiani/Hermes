package edu.wustl.onl.envoylocalproxy

import android.content.Intent

object Settings {
    var envoyName: String="envoymobile"
    var startstate=false
    var intent:Intent?=null
    var mode:String="Static"
    var statsdPort:Int= 8125
    var statsdAddress:String="192.168.10.10"
    var xDSPort:Int= 18000
    var xDSAddress:String="192.168.6.1"
    var StateString="Service is not running"
    var stoplog=false
}