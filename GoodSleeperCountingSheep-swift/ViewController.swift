//
//  ViewController.swift
//  GoodSleeperCountingSheep-swift
//
//  Created by Phil on 2025/3/29.
//

import UIKit
import SpriteKit
import GoogleMobileAds

class ViewController: UIViewController, BviewControllerDelegate, FullScreenContentDelegate, BannerViewDelegate {
    func BviewcontrollerDidTapButton() {
        
    }
    
    func BviewcontrollerDidTapBackToMenuButton() {
        
    }
    
    @IBOutlet weak var skView: SKView!
    private var scene: MyScene?
    private var adBannerView: BannerView!
    private var interstitial: InterstitialAd!
    private var isFirstLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        adBannerView = BannerView(frame: CGRect(x: 0, y: -50, width: 200, height: 30))
        adBannerView.delegate = self
        adBannerView.alpha = 1.0
        self.view.addSubview(adBannerView)

        print("Google Mobile Ads SDK version: \(Request.version())")
        
        Task {
            try await createAndLoadInterstitial()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if isFirstLoad {
            isFirstLoad = false

            scene = MyScene(size: skView.frame.size)
            scene?.scaleMode = .aspectFill
            skView.presentScene(scene)

            scene?.onGameOver = { [weak self] score in
                self?.showScore(score)
            }

            scene?.showAdmob = { [weak self] in
                self?.showAdmob()
            }
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func showScore(_ gameScore: Int) {
        guard let gameOverVC = storyboard?.instantiateViewController(withIdentifier: "GameOverViewController") as? GameOverViewController else { return }

        gameOverVC.delegate = self
        gameOverVC.gameScore = gameScore

        navigationController?.modalPresentationStyle = .currentContext
        navigationController?.present(gameOverVC, animated: true, completion: nil)
    }

    private func showAdmob() {
        if let interstitial = interstitial {
            interstitial.present(from: self)
        } else {
            print("⚠️ Ad wasn't ready")
        }
    }

    private func layoutBanner(loaded: Bool , animated: Bool) {
        var contentFrame = view.bounds
        var bannerFrame = adBannerView.frame
        
        if loaded {
            contentFrame.size.height = 0
            bannerFrame.origin.y = contentFrame.size.height
        } else {
            bannerFrame.origin.y = contentFrame.size.height
        }

        UIView.animate(withDuration: animated ? 0.25 : 0.0) {
            self.adBannerView.frame = contentFrame
            self.adBannerView.layoutIfNeeded()
            self.adBannerView.frame = bannerFrame
        }
    }

    private func createAndLoadInterstitial() async throws {
        let ad = try await InterstitialAd.load(with: "ca-app-pub-2566742856382887/8779587052")
        self.interstitial = ad
    }
    
    // MARK: - FullScreenContentDelegate Methods

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("✅ Interstitial ad was dismissed.")
        Task {
            try await createAndLoadInterstitial()
        }
    }
    
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        layoutBanner(loaded: true, animated: true)
    }
    
    func ad(_ ad: any FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: any Error) {
        layoutBanner(loaded: false, animated: true)
    }
}
