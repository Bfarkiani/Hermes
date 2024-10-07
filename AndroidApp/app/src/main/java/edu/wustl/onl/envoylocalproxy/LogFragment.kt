package edu.wustl.onl.envoylocalproxy

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import edu.wustl.onl.envoylocalproxy.databinding.FragmentLogBinding

class LogFragment: Fragment() {
    private lateinit var binding: FragmentLogBinding
    private val logAdapter = LogAdaptor()

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        binding= FragmentLogBinding.inflate(inflater,container,false)
        binding.clearLogButton.setOnClickListener {
            LogStorage.clearLogs()
            logAdapter.updateLog(LogStorage.logs.toList())
            logAdapter.notifyDataSetChanged()
        }
        binding.stoplogButton.setOnClickListener {
            if (LogStorage.liveDataLogs.hasObservers()) {
                if (binding.stoplogButton.text.toString().uppercase() == "STOP LOG") {
                    binding.stoplogButton.text = "Start Log"
                    LogStorage.liveDataLogs.removeObservers(viewLifecycleOwner)
                } else {
                    binding.stoplogButton.text = "Stop Log"
                    LogStorage.liveDataLogs.observe(
                        viewLifecycleOwner,
                        Observer { newLogs ->
                            logAdapter.updateLog(newLogs)
                            logAdapter.notifyDataSetChanged()
                            binding.logRecyclerView.scrollToPosition(LogStorage.logs.size - 1);
                        })
                }
            }
        }
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.clearLogButton.setOnClickListener {
            LogStorage.clearLogs()
            logAdapter.updateLog(LogStorage.logs.toList())
            logAdapter.notifyDataSetChanged()
        }
        binding.stoplogButton.setOnClickListener {
                if (binding.stoplogButton.text.toString().uppercase() == "STOP LOG") {
                    binding.stoplogButton.text = "Start Log"
                    LogStorage.liveDataLogs.removeObservers(viewLifecycleOwner)
                } else {
                    binding.stoplogButton.text = "Stop Log"
                    LogStorage.liveDataLogs.observe(
                        viewLifecycleOwner,
                        Observer { newLogs ->
                            logAdapter.updateLog(newLogs)
                            logAdapter.notifyDataSetChanged()
                            binding.logRecyclerView.scrollToPosition(LogStorage.logs.size - 1);
                        })
                    logAdapter.notifyDataSetChanged()
                }
            }

        logCreation()
    }



    private fun logCreation() {
        binding.logRecyclerView.adapter = logAdapter
        binding.logRecyclerView.layoutManager = LinearLayoutManager(requireContext())
        val dividerItemDecoration = DividerItemDecoration(
            binding.logRecyclerView.context,
            (binding.logRecyclerView.layoutManager as LinearLayoutManager).orientation
        )
        binding.logRecyclerView.addItemDecoration(dividerItemDecoration)
        logAdapter.updateLog(LogStorage.logs.toList())
        binding.logRecyclerView.scrollToPosition(LogStorage.logs.size - 1);

        LogStorage.liveDataLogs.observe(viewLifecycleOwner, Observer { newLogs ->
            logAdapter.updateLog(newLogs)
            logAdapter.notifyDataSetChanged()
            binding.logRecyclerView.scrollToPosition(LogStorage.logs.size - 1);
        })
    }



}