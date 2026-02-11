package com.example.a167lablearnandroid.architecture.mvc

class MvcCounterModel {
    private var count = 0

    fun getCount(): Int {
        return count
    }

    fun incrementCounter() {
        count++
    }
}
