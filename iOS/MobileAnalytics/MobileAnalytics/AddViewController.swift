//
//  AddViewController.swift
//  MobileAnalytics
//
//  Created by Anton on 5/21/15.
//
//

import Foundation
import UIKit
import GoogleMobileAds

class AddViewController: GAITrackedViewController, GADBannerViewDelegate, GADInterstitialDelegate {

	@IBOutlet weak var banner: UIView!
	var bannerView: GADBannerView!
	var interstitial: GADInterstitial?

	override func viewDidLoad() {
		super.viewDidLoad()

		println("ad sdk vervion \(GADRequest.sdkVersion())")
		var bannerView = GADBannerView(frame: banner.bounds)
		banner.addSubview(bannerView)

		bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
		bannerView.rootViewController = self as UIViewController

		var request = GADRequest()
		request.testDevices = [kGADSimulatorID]
		request.contentURL = "http://horseheads.ru"
		bannerView.loadRequest(GADRequest())
		bannerView.delegate = self

		self.interstitial = self.createInterstitial()
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		self.screenName = "Add Screen"
	}
	@IBAction func addThingAction(sender: AnyObject) {
		var dict = GAIDictionaryBuilder.createEventWithCategory(kGAICategoryThing, action: kGAIActionAddThing, label: "Label add", value: NSNumber(integer: 0)).build() as [NSObject : AnyObject]
		GAI.sharedInstance().defaultTracker.send(dict)
	}
	@IBAction func deleteThingAction(sender: AnyObject) {
		var dict = GAIDictionaryBuilder.createEventWithCategory(kGAICategoryThing, action: kGAIActionDeleteThing, label: "Label delete", value: NSNumber(integer: 0)).build() as [NSObject : AnyObject]
		GAI.sharedInstance().defaultTracker.send(dict)
	}
	@IBAction func buyThingAction(sender: AnyObject) {
		self.interstitial?.presentFromRootViewController(self)
	}
	@IBAction func throwExceptionAction(sender: AnyObject) {
		var dict = GAIDictionaryBuilder.createExceptionWithDescription("Fatal exception!!!", withFatal: NSNumber(integer: 555)).build() as [NSObject : AnyObject]
		GAI.sharedInstance().defaultTracker.send(dict)
	}

	private func createInterstitial() -> GADInterstitial {
		var request = GADRequest()
		request.testDevices = [kGADSimulatorID]
		request.contentURL = "http://horseheads.ru"
		var inter = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
		inter.delegate = self
		inter.loadRequest(request)
		return inter
	}
	func interstitialDidDismissScreen(ad: GADInterstitial!) {
		self.interstitial = self.createInterstitial()
	}
}