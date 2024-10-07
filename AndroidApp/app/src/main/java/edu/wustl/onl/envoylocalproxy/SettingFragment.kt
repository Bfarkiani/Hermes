package edu.wustl.onl.envoylocalproxy

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import androidx.fragment.app.Fragment
import edu.wustl.onl.envoylocalproxy.databinding.FragmentSettingBinding

class SettingFragment:Fragment() {
    private var serviceStarted=false
    private lateinit var binding: FragmentSettingBinding
    private lateinit var intent: Intent
    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        binding= FragmentSettingBinding.inflate(inflater,container,false)
        binding.startstopButton.setOnClickListener {
            buttonClick()
        }
        return binding.root
    }



    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.radioGroup.setOnCheckedChangeListener { _, i ->
            if(i==R.id.staticRadioButton) {
                disablexDS()
            }
            else if(i==R.id.dynamicRadioButton ) {
                enablexDS()
            }else if (i==R.id.dynamicSecureRadioButton){
                enablexDS()
            }
        }
        //read current status from Settings
        serviceStarted=Settings.startstate
        if(!serviceStarted) {
            binding.startstopButton.text="Start Service"
            binding.staticRadioButton.isChecked=true
            disablexDS()
        }
        else {
            binding.startstopButton.text="Stop Service"
            var rsa=Settings.mode
            if(rsa=="Static") {//static
                binding.staticRadioButton.isChecked=true
                disablexDS()
            }
            else {
                if(rsa=="DynamicSecure")
                    binding.dynamicSecureRadioButton.isChecked=true
                else if(rsa=="Dynamic")
                    binding.dynamicRadioButton.isChecked=true
                enablexDS()

            }
            binding.statsdportEditText.setText(Settings.statsdPort.toString())
            binding.statsdIPEditText.setText(Settings.statsdAddress)
            if(rsa!="Static"){//dynamic
                binding.xdsPortEditText.setText(Settings.xDSPort.toString())
                binding.xdsIPEditText.setText(Settings.xDSAddress)
            }
            binding.serviceStatusTextView.text=Settings.StateString
            binding.nameEditText.setText(Settings.envoyName)

        }
    }

    private fun buttonClick() {
        if(binding.startstopButton.text.toString().uppercase()=="START SERVICE") {
            binding.startstopButton.text="Stop Service"
            startService()
        }
        else if(binding.startstopButton.text.toString().uppercase()=="STOP SERVICE") {
            binding.startstopButton.text="Start Service"
            stopService()
        }
    }

    private fun stopService() {
        serviceStarted=Settings.startstate
        if(serviceStarted==true){
            intent=Settings.intent!!
            getActivity()?.stopService(intent)
            binding.serviceStatusTextView.text="Envoy is stopped"
        }else{
            Toast.makeText(activity,"Service already stopped",Toast.LENGTH_SHORT).show()
        }
        LogStorage.addLog("Service Stopped.")
        serviceStarted=false
        Settings.startstate=false
    }

    private fun startService() {
        serviceStarted=Settings.startstate
        if(serviceStarted==false){
            if(binding.staticRadioButton.isChecked) {
                val statsDPort=binding.statsdportEditText.text.toString().toInt()
                val statsDIP=binding.statsdIPEditText.text.toString()
                val envoyName=binding.nameEditText.text.toString()
                Settings.envoyName=envoyName
                intent = Intent(activity, LocalProxy()::class.java)
                Settings.mode="Static"
                Settings.statsdPort=statsDPort
                Settings.statsdAddress=statsDIP
                Settings.startstate=true
                Settings.intent=intent


                getActivity()?.startService(intent)
                Settings.StateString="Envoy is running in background with Static mode Config:\n " +
                        "StatsD address: $statsDIP , StatsD port: $statsDPort \n"+
                        "http://httpforever.com is returned as Hello World! \n"+
                        "All other sites are proxied as normal"
                binding.serviceStatusTextView.text=Settings.StateString

            }
            else if(binding.dynamicRadioButton.isChecked) {
                val statsDPort=binding.statsdportEditText.text.toString().toInt()
                val statsDIP=binding.statsdIPEditText.text.toString()
                val xDSPort=binding.xdsPortEditText.text.toString().toInt()
                val xdsIP=binding.xdsIPEditText.text.toString()
                val envoyName=binding.nameEditText.text.toString()
                Settings.envoyName=envoyName
                Settings.mode="Dynamic"
                Settings.statsdPort=statsDPort
                Settings.statsdAddress=statsDIP
                Settings.xDSPort=xDSPort
                Settings.xDSAddress=xdsIP
                Settings.startstate=true
                intent = Intent(activity, LocalProxy()::class.java)

                Settings.intent=intent
                getActivity()?.startService(intent)
                Settings.StateString="Envoy is running in background with Dynamic mode Config:\n " +
                        "StatsD address: $statsDIP, StatsD port: $statsDPort, xDS address: $xdsIP, xDS port: $xDSPort"
                binding.serviceStatusTextView.text=Settings.StateString

            }
            else if(binding.dynamicSecureRadioButton.isChecked ){
                val statsDPort=binding.statsdportEditText.text.toString().toInt()
                val statsDIP=binding.statsdIPEditText.text.toString()
                val xDSPort=binding.xdsPortEditText.text.toString().toInt()
                val xdsIP=binding.xdsIPEditText.text.toString()
                val envoyName=binding.nameEditText.text.toString()
                Settings.mode="DynamicSecure"
                Settings.statsdPort=statsDPort
                Settings.statsdAddress=statsDIP
                Settings.xDSPort=xDSPort
                Settings.xDSAddress=xdsIP
                Settings.startstate=true
                Settings.envoyName=envoyName
                intent = Intent(activity, LocalProxy()::class.java)

                Settings.intent=intent
                getActivity()?.startService(intent)
                Settings.StateString="Envoy is running in background with Dynamic mode Config:\n " +
                        "StatsD address: $statsDIP, StatsD port: $statsDPort, xDS address: $xdsIP, xDS port: $xDSPort"
                binding.serviceStatusTextView.text=Settings.StateString


            }
        }else {
            Toast.makeText(activity,"Service already started",Toast.LENGTH_SHORT).show()
        }
        LogStorage.addLog("Service Started")
        serviceStarted=true
    }

    private fun enablexDS() {
        binding.xdsIP.setFocusable(true)
        binding.xdsPort.setEnabled(true)
        binding.xdsIP.setEnabled(true)
        binding.xdsPort.setFocusable(true)
    }

    private fun disablexDS() {
        binding.xdsIP.setFocusable(false)
        binding.xdsPort.setEnabled(false)
        binding.xdsIP.setEnabled(false)
        binding.xdsPort.setFocusable(false)
    }
}