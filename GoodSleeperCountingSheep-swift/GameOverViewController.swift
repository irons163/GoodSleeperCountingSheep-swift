//
//  GameOverViewController.swift
//  GoodSleeperCountingSheep-swift
//
//  Created by Phil on 2025/3/29.
//

import UIKit

protocol BviewControllerDelegate: AnyObject {
    func BviewcontrollerDidTapButton()
    func BviewcontrollerDidTapBackToMenuButton()
}

class GameOverViewController: UIViewController {

    var gameScore: Int = 0

    @IBOutlet weak var gameLevelTensDigitalLabel: UIImageView!
    @IBOutlet weak var gameLevelSingleDigital: UIImageView!
    @IBOutlet weak var gameTimeMinuteTensDIgitalLabel: UIImageView!
    @IBOutlet weak var gameTimeMinuteSingleDigitalLabel: UIImageView!
    @IBOutlet weak var gameTimeSecondTensDigitalLabel: UIImageView!
    @IBOutlet weak var gameTimeSecondSingleDigitalLabel: UIImageView!

    weak var delegate: BviewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        gameTimeMinuteTensDIgitalLabel.image = getNumberImage(gameScore / 60 / 10)
        gameTimeMinuteSingleDigitalLabel.image = getNumberImage(gameScore / 60 % 10)
        gameTimeSecondTensDigitalLabel.image = getNumberImage((gameScore % 60) / 10)
        gameTimeSecondSingleDigitalLabel.image = getNumberImage((gameScore % 60) % 10)
    }

    @IBAction func restartGameClick(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.BviewcontrollerDidTapButton()
        }
    }

    @IBAction func backToMainMenuClick(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            self?.delegate?.BviewcontrollerDidTapBackToMenuButton()
        }
    }

    private func getNumberImage(_ number: Int) -> UIImage? {
        let images = TextureHelper.timeImages()
        guard number >= 0 && number < images.count else { return nil }
        return images[number]
    }
}
