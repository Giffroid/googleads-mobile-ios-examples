//
//  Copyright (C) 2015 Google, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import GoogleMobileAds
import UIKit

class ViewController: UIViewController, GADInterstitialDelegate, UIAlertViewDelegate {

  enum GameState: NSInteger {
    case NotStarted
    case Playing
    case Paused
    case Ended
  }

  /// The interstitial ad.
  var interstitial: GADInterstitial!

  /// The countdown timer.
  var timer: NSTimer?

  /// The game counter.
  var counter = 3

  /// The state of the game.
  var gameState = GameState.NotStarted

  /// The date that the timer was paused.
  var pauseDate: NSDate?

  /// The last fire date before a pause.
  var previousFireDate: NSDate?

  /// The countdown timer label.
  @IBOutlet weak var gameText: UILabel!

  /// The play again button.
  @IBOutlet weak var playAgainButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()
    startNewGame()
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    pauseGame()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    resumeGame()
  }

  // MARK: - Game Logic

  func startNewGame() {
    gameState = .Playing
    counter = 3
    playAgainButton.hidden = true
    loadInterstitial()
    gameText.text = String(counter)
    timer = NSTimer.scheduledTimerWithTimeInterval(1.0,
        target: self,
        selector:#selector(ViewController.decrementCounter(_:)),
        userInfo: nil,
        repeats: true)
  }

  func pauseGame() {
    if gameState != .Playing {
      return
    }
    gameState = .Paused

    // Record the relevant pause times.
    pauseDate = NSDate()
    previousFireDate = timer!.fireDate

    // Prevent the timer from firing while app is in background.
    timer!.fireDate = NSDate.distantFuture()
  }

  func resumeGame() {
    if gameState != .Paused {
      return
    }
    gameState = .Playing

    // Calculate amount of time the app was paused.
    let pauseTime = pauseDate!.timeIntervalSinceNow * -1

    // Set the timer to start firing again.
    timer!.fireDate = previousFireDate!.dateByAddingTimeInterval(pauseTime)
  }

  func decrementCounter(timer: NSTimer) {
    counter -= 1
    if counter > 0 {
      gameText.text = String(counter)
    } else {
      endGame()
    }
  }

  func endGame() {
    gameState = .Ended
    gameText.text = "Game over!"
    playAgainButton.hidden = false
    timer!.invalidate()
    timer = nil
  }

  // MARK: - Interstitial Button Actions

  @IBAction func playAgain(sender: AnyObject) {
    if interstitial.isReady {
      interstitial.presentFromRootViewController(self)
    } else {
      UIAlertView(title: "Interstitial not ready",
          message: "The interstitial didn't finish loading or failed to load",
          delegate: self,
          cancelButtonTitle: "Drat").show()
    }
  }

  func loadInterstitial() {
    interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
    interstitial.delegate = self

    // Request test ads on devices you specify. Your test device ID is printed to the console when
    // an ad request is made. GADInterstitial automatically returns test ads when running on a
    // simulator.
    interstitial.loadRequest(GADRequest())
  }

  // MARK: - UIAlertViewDelegate

  func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
    startNewGame()
  }

  // MARK: - GADInterstitialDelegate

  func interstitialDidFailToReceiveAdWithError(interstitial: GADInterstitial,
      error: GADRequestError) {
    print("\(#function): \(error.localizedDescription)")
  }

  func interstitialDidDismissScreen(interstitial: GADInterstitial) {
    print(#function)
    startNewGame()
  }

}
