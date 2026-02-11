package com.example.a167lablearnandroid.architecture.mvp

import com.example.a167lablearnandroid.architecture.mvp.MvpCounterView

class MvpCounterPresenter(
    private val view: MvpCounterView,
    private val model: MvpCounterModel
) {

    fun onIncrementClicked() {
        model.incrementCounter()
        val newCount = model.getCount()
        view.showCount(newCount)
    }
}
