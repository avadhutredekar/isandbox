//
//  ADViewController.swift
//  MobileAnalytics
//
//  Created by Anton Davydov on 5/21/15.
//
//

import Foundation
import UIKit
import iAd

class ADViewController: UIViewController, ADBannerViewDelegate, ADInterstitialAdDelegate {

	@IBOutlet weak var banner: ADBannerView!
	var interstitial = ADInterstitialAd()

	override func viewDidLoad() {
		super.viewDidLoad()

		self.canDisplayBannerAds = true
		self.banner.hidden = true
		self.interstitial.delegate = self
	}

	func bannerViewDidLoadAd(banner: ADBannerView!) {
		self.banner.hidden = false
	}

	@IBAction func showAdAction(sender: AnyObject) {
		if self.interstitial.loaded {
			self.interstitial.presentInView(self.view)
		}
	}

	func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
		return true
	}

	func interstitialAdActionShouldBegin(interstitialAd: ADInterstitialAd!, willLeaveApplication willLeave: Bool) -> Bool {
		return true
	}

	func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {

	}

	func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
		
	}
}