//
//  ViewController.swift
//  PeakVoiceViewDemo
//
//  Created by Anton Davydov on 5/19/15.
//  Copyright (c) 2015 dydus0x14. All rights reserved.
//

import UIKit
import PeakVoiceView
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {
	private var session: AVAudioSession?
	private var record: AVAudioRecorder?
	private var timer: NSTimer?
	private var path: String?

	@IBOutlet weak var meterView: PeakVoiceView!

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		session = AVAudioSession.sharedInstance()

		var error: NSError?
		if session?.setCategory(AVAudioSessionCategoryPlayAndRecord, error:&error) == false {
			println("could not set session category")
			if let e = error {
				println(e.localizedDescription)
			}
		}
		if session?.setActive(true, error: &error) == false {
			println("could not make session active")
			if let e = error {
				println(e.localizedDescription)
			}
		}

		let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
		let docsDir = dirPaths[0] as! String
		self.path = docsDir.stringByAppendingPathComponent("sound.aac")

		if let notNullPath = self.path, outputFileUrl = NSURL(fileURLWithPath: notNullPath) {
			let recordSettings = [AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue,
				AVFormatIDKey: kAudioFormatMPEG4AAC,
				AVNumberOfChannelsKey: 2,
				AVEncoderBitRateKey: 16,
				AVSampleRateKey: 44100.0]
			self.record = AVAudioRecorder(URL: outputFileUrl, settings: recordSettings as [NSObject : AnyObject], error: nil)
		}
		record?.delegate = self
		record?.meteringEnabled = true
		record?.prepareToRecord()

		session?.requestRecordPermission { (granted: Bool) -> () in
			if granted {
			} else {
				println("Not granted")
			}
		}

	}

	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)

		self.viewTapAction(self)
	}

	func updateAudioMeter(timer: NSTimer) {
		if (record?.recording == true) {
			record!.updateMeters()
			var peak = record!.peakPowerForChannel(0)
			println("peak=\(peak)")
			self.meterView.peak = CGFloat(0.8 - peak / -60.0)
		}
	}

	@IBAction func viewTapAction(sender: AnyObject) {
		if record?.recording == true {
			self.timer?.invalidate()
			self.timer = nil
			record?.stop()
		} else {
			self.timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target:self, selector:Selector("updateAudioMeter:"), userInfo:nil,repeats:true)
			record?.record()
		}
	}
	
	func stopTakingIfNeeded() {
		if record?.recording == true {
			record?.stop()
		}
	}

	func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
		println("Audio Record Finish")
	}

	func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: NSError!) {
		println("Audio Record Encode Error")
	}

}

