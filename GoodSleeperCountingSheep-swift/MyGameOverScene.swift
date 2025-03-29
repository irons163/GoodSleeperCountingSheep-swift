//
//  MyGameOverScene.swift
//  GoodSleeperCountingSheep-swift
//
//  Created by Phil on 2025/3/29.
//

import SpriteKit

class MyGameOverScene: SKScene {

    weak var sceneTransitionDelegate: ReturnToMySceneDelegate?
    var periousScene: SKScene?
    var lastSpawnTimeInterval: TimeInterval = 0
    var lastUpdateTimeInterval: TimeInterval = 0

    private var continueBtn: SKSpriteNode!
    private var sheepStandNode: SKSpriteNode!
    private var ccount: Int = 0

    override init(size: CGSize) {
        super.init(size: size)
        setupScene()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupScene() {
        let backgroundNode = SKSpriteNode(imageNamed: "bg02")
        backgroundNode.size = self.size
        backgroundNode.anchorPoint = CGPoint(x: 0, y: 0)
        backgroundNode.position = CGPoint(x: 0, y: 0)
        addChild(backgroundNode)

        continueBtn = SKSpriteNode(imageNamed: "sheep_text2")
        continueBtn.anchorPoint = CGPoint(x: 0, y: 0)
        continueBtn.size = CGSize(width: size.width / 3, height: size.height / 5)
        continueBtn.position = CGPoint(x: 0, y: 0)
        addChild(continueBtn)

        sheepStandNode = SKSpriteNode(imageNamed: "sheep1")
        sheepStandNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        sheepStandNode.size = CGSize(width: size.width * 3 / 5, height: size.height * 9 / 10)
        sheepStandNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(sheepStandNode)
    }

    override func update(_ currentTime: TimeInterval) {
        var timeSinceLast = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime

        if timeSinceLast > 1 {
            timeSinceLast = 1.0 / 60.0
            lastUpdateTimeInterval = currentTime
        }

        updateWithTimeSinceLastUpdate(timeSinceLast)
    }

    private func updateWithTimeSinceLastUpdate(_ timeSinceLast: TimeInterval) {
        lastSpawnTimeInterval += timeSinceLast

        if lastSpawnTimeInterval > 0.5 {
            lastSpawnTimeInterval = 0
            ccount += 1
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if continueBtn.contains(location) {
            if let view = self.view, let previous = periousScene {
                view.presentScene(previous)
                sceneTransitionDelegate?.startTimer()
            }
        }
    }
}
