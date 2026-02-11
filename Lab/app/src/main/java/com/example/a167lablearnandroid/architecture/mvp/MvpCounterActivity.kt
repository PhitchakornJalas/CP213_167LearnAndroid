package com.example.a167lablearnandroid.architecture.mvp

import android.annotation.SuppressLint
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.example.a167lablearnandroid.architecture.mvp.MvpCounterModel
import com.example.a167lablearnandroid.architecture.mvp.MvpCounterPresenter
import com.example.a167lablearnandroid.architecture.mvp.MvpCounterView
import com.example.a167lablearnandroid.R

class MvpCounterActivity : AppCompatActivity(), MvpCounterView {

    private lateinit var tvCount: TextView
    private lateinit var btnIncrement: Button

    private lateinit var presenter: MvpCounterPresenter

    @SuppressLint("MissingInflatedId")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_counter_classic)

        // Initialize View References
        tvCount = findViewById(R.id.tvCount)
        btnIncrement = findViewById(R.id.btnIncrement)

        // Initialize Presenter
        presenter = MvpCounterPresenter(this, MvpCounterModel())

        // Pass events to Presenter
        btnIncrement.setOnClickListener {
            presenter.onIncrementClicked()
        }
    }

    // View Implementation (Passive View)
    @SuppressLint("SetTextI18n")
    override fun showCount(count: Int) {
        tvCount.text = "Count: $count"
    }
}
