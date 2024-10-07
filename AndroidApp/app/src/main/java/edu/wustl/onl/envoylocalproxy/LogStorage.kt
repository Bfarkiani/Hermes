package edu.wustl.onl.envoylocalproxy

import androidx.lifecycle.MutableLiveData
import java.util.ArrayList

object LogStorage {
    val logs = mutableListOf<String>()
    val liveDataLogs = MutableLiveData<List<String>>()

    fun addLog(log: String) {
        logs.add(log)
        liveDataLogs.postValue(ArrayList(logs))
    }
    fun clearLogs() {
        logs.clear()
        liveDataLogs.postValue(ArrayList(logs))
    }
}
