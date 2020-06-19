package com.yqb.flutterdemo

import android.animation.Animator
import android.content.Context
import android.graphics.Color
import android.os.Bundle
import android.os.Handler
import android.text.SpannableString
import android.text.Spanned.SPAN_INCLUSIVE_EXCLUSIVE
import android.text.style.ForegroundColorSpan
import android.view.LayoutInflater
import android.view.View
import android.widget.TextView
import io.flutter.embedding.android.SplashScreen

class CustomSplashScreen : SplashScreen {
    private val handler = Handler()
    private var second: Int = 2
    private var onTransitionComplete: Runnable? = null
    override fun createSplashView(context: Context, savedInstanceState: Bundle?): View? {
        val view = LayoutInflater.from(context).inflate(R.layout.view_splash_screen, null)
        val textView: TextView = view.findViewById(R.id.skipView)

        val runnable = object : Runnable {
            override fun run() {
                if (second <= 1) {
                    animatedAway(view)
                    return
                }
                second--
                updateSecond(textView)
                handler.postDelayed(this, 1000)
            }
        }
        textView.setOnClickListener {
            animatedAway(view)
            handler.removeCallbacks(runnable)
        }
        updateSecond(textView)
        handler.postDelayed(runnable, 1000)
        return view
    }

    fun updateSecond(textView: TextView) {
        val spannable = SpannableString("跳过 $second")
        val foregroundColorSpan = ForegroundColorSpan(Color.RED)
        spannable.setSpan(foregroundColorSpan, 3, 4, SPAN_INCLUSIVE_EXCLUSIVE)
        textView.text = spannable
    }

    fun animatedAway(view: View) {
        view.animate().setListener(object : Animator.AnimatorListener {
            override fun onAnimationRepeat(animation: Animator?) {
            }

            override fun onAnimationEnd(animation: Animator?) {
                onTransitionComplete?.run()
            }

            override fun onAnimationCancel(animation: Animator?) {
            }

            override fun onAnimationStart(animation: Animator?) {
            }
        }).translationXBy(-1f * view.width).alpha(0f).setDuration(300).start()
    }

    override fun transitionToFlutter(onTransitionComplete: Runnable) {
        this.onTransitionComplete = onTransitionComplete
    }
}