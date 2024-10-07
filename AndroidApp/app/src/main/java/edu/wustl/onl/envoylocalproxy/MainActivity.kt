package edu.wustl.onl.envoylocalproxy

import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.MenuItem
import androidx.fragment.app.commit
import com.google.android.material.navigation.NavigationBarView
import edu.wustl.onl.envoylocalproxy.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity(), NavigationBarView.OnItemSelectedListener {
    private lateinit var binding: ActivityMainBinding
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        binding.bottomNavigationView.setOnItemSelectedListener (this)
    }

    private fun logFragment() {
        supportFragmentManager.commit {
            replace(R.id.fragmentContainer,LogFragment())
        }
    }


    private fun settingFragment() {
        supportFragmentManager.commit {
            replace(R.id.fragmentContainer,SettingFragment())
        }
    }

    override fun onNavigationItemSelected(item: MenuItem): Boolean {
        if(item.itemId==R.id.logFragment) {
            logFragment()
            return true
        }

        else if(item.itemId==R.id.settingFragment) {
            settingFragment()
            return true
        }
        return false
    }
}