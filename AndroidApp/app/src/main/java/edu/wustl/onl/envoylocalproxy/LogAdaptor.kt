package edu.wustl.onl.envoylocalproxy

import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import edu.wustl.onl.envoylocalproxy.databinding.LogItemBinding

class LogAdaptor : RecyclerView.Adapter<LogAdaptor.LogViewHolder>() {

    private var logs = mutableListOf<String>()

    fun updateLog(newLogs: List<String>) {
        logs.clear()
        logs.addAll(newLogs)
        notifyDataSetChanged()
    }
    class LogViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val logItem = LogItemBinding.bind(itemView).logItem
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): LogViewHolder {
        return LogViewHolder(
            LayoutInflater.from(parent.context).inflate(R.layout.log_item, parent, false)
        )
    }

    override fun getItemCount(): Int {
        return logs.size
    }

    override fun onBindViewHolder(holder: LogViewHolder, position: Int) {
        LogItemBinding.bind(holder.itemView).apply {
            logItem.text = logs[position]
        }
    }




}