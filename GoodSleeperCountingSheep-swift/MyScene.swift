//
//  MyScene.swift
//  GoodSleeperCountingSheep-swift
//
//  Created by Phil on 2025/3/29.
//

import SpriteKit
import AVFoundation

protocol ReturnToMySceneDelegate: AnyObject {
    func startTimer()
}

class MyScene: SKScene, ReturnToMySceneDelegate {

    typealias GameOverDialog = (Int) -> Void
    var onGameOver: GameOverDialog?

    typealias Admob = () -> Void
    var showAdmob: Admob?

    var lastSpawnTimeInterval: TimeInterval = 0
    var lastUpdateTimeInterval: TimeInterval = 0

    private var bar: SKSpriteNode!
    private var barHeight: Int = 0
    private var touching = false

    private let sheepLeftMax = 6
    private var sheepArray = [SKSpriteNode]()
    private var sheepArrayLeft = [SKSpriteNode]()

    private var gamePointSingleNode: SKSpriteNode!
    private var gamePointTenNode: SKSpriteNode!
    private var gamePointHunNode: SKSpriteNode!
    private var gamePointTHUNode: SKSpriteNode!
    private var sheepTextNode: SKSpriteNode!

    private var sheepGameScore = 0
    private var gamePointX = 0
    private var isGameRun = true
    private var ccount = 0
    private var timer: Timer?
    private var isSheepTouchable = true
    private var periousTime: Double = 0

    override init(size: CGSize) {
        super.init(size: size)
        setupScene()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupScene() {
        let backgroundNode = SKSpriteNode(imageNamed: "bg01")
        backgroundNode.size = self.frame.size
        backgroundNode.anchorPoint = CGPoint(x: 0, y: 0)
        backgroundNode.position = CGPoint(x: 0, y: 0)
        addChild(backgroundNode)

        let gamePointNodeWH = 30
        gamePointX = Int(self.frame.width) / 4
        let gamePointY = Int(self.frame.height) * 6 / 8

        gamePointSingleNode = SKSpriteNode(texture: getTimeTexture(sheepGameScore % 10))
        gamePointSingleNode.anchorPoint = CGPoint(x: 0, y: 0)
        gamePointSingleNode.size = CGSize(width: gamePointNodeWH, height: gamePointNodeWH)
        gamePointSingleNode.position = CGPoint(x: gamePointX, y: gamePointY)

        gamePointTenNode = SKSpriteNode(texture: getTimeTexture((sheepGameScore / 10) % 10))
        gamePointTenNode.anchorPoint = CGPoint(x: 0, y: 0)
        gamePointTenNode.size = CGSize(width: gamePointNodeWH, height: gamePointNodeWH)
        gamePointTenNode.position = CGPoint(x: gamePointX - gamePointNodeWH, y: gamePointY)

        gamePointHunNode = SKSpriteNode(texture: getTimeTexture((sheepGameScore / 100) % 10))
        gamePointHunNode.anchorPoint = CGPoint(x: 0, y: 0)
        gamePointHunNode.size = CGSize(width: gamePointNodeWH, height: gamePointNodeWH)
        gamePointHunNode.position = CGPoint(x: gamePointX - 2 * gamePointNodeWH, y: gamePointY)

        gamePointTHUNode = SKSpriteNode(texture: getTimeTexture((sheepGameScore / 1000) % 10))
        gamePointTHUNode.anchorPoint = CGPoint(x: 0, y: 0)
        gamePointTHUNode.size = CGSize(width: gamePointNodeWH, height: gamePointNodeWH)
        gamePointTHUNode.position = CGPoint(x: gamePointX - 3 * gamePointNodeWH, y: gamePointY)

        addChild(gamePointSingleNode)
        addChild(gamePointTenNode)
        addChild(gamePointHunNode)
        addChild(gamePointTHUNode)

        sheepTextNode = SKSpriteNode(imageNamed: "sheep_text")
        sheepTextNode.anchorPoint = CGPoint(x: 0, y: 0)
        sheepTextNode.size = CGSize(width: Double(gamePointNodeWH) * 4.2, height: Double(gamePointNodeWH) * 1.5)
        sheepTextNode.position = CGPoint(x: gamePointX - gamePointNodeWH * 3, y: gamePointY - gamePointNodeWH - 10)
        addChild(sheepTextNode)

        barHeight = Int(self.frame.height * 4 / 5.0)
        bar = SKSpriteNode(imageNamed: "bar")
        bar.size = CGSize(width: 50, height: barHeight)
        bar.position = CGPoint(x: self.frame.width / 3, y: self.frame.height / 2 - CGFloat(barHeight) / 6)
        addChild(bar)

        for _ in 0..<10 {
            let sheep = createSheep()
            sheepArray.append(sheep)
            addChild(sheep)
        }

        startTimer()
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] _ in
            self?.showScore()
        }
    }
    
    func showScore() {
        moveTrans()
    }

    func moveTrans() {
        guard let view = self.view else { return }
        let scoreScene = MyGameScoreScene(size: view.frame.size)
        scoreScene.scaleMode = self.scaleMode
        scoreScene.periousScene = self
        scoreScene.sheepGameScore = sheepGameScore
        scoreScene.updateSheepGameScore = true
        scoreScene.sceneTransitionDelegate = self

        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        view.presentScene(scoreScene, transition: transition)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        timer?.invalidate()
        startTimer()

        guard isSheepTouchable, !touching, let touch = touches.first else { return }
        touching = true
        let location = touch.location(in: self)

        for (index, sheep) in sheepArray.enumerated() {
            if sheep.contains(location) {
                sheep.removeAllActions()
                sheepArray.remove(at: index)
                let newSheep = createSheep()
                sheepArray.append(newSheep)
                addChild(newSheep)

                sheep.texture = SKTexture(imageNamed: "sheep_jump1")
                sheep.xScale = 1

                let up = SKAction.moveBy(x: 0, y: 50, duration: 0.5)
                up.timingMode = .easeOut
                let down = SKAction.moveBy(x: 0, y: -50, duration: 0.5)
                down.timingMode = .easeIn

                let upEnd = SKAction.run {
                    sheep.texture = SKTexture(imageNamed: "sheep_jump3")
                }

                let horz = SKAction.moveTo(x: 50, duration: 1.0)
                let currentTime = Date().timeIntervalSince1970 * 1000

                let end: SKAction

                if currentTime - periousTime > 500 {
                    end = SKAction.run { [self] in
                        sheep.removeAllActions()
                        sheepArrayLeft.append(sheep)
                        trimSheepLeft()
                        changeGamePoint()
                        sheepWalkL(sheep)
                    }
                } else if currentTime - periousTime < 200, sheepArrayLeft.count >= sheepLeftMax {
                    end = SKAction.run { [self] in
                        sheep.removeAllActions()
                        sheepArrayLeft.append(sheep)
                        changeGamePoint()

                        if isSheepTouchable {
                            sheep.texture = SKTexture(imageNamed: "sheep_angry01")
                            let scale = SKAction.scale(to: 8, duration: 2)
                            let bumpEnd = SKAction.run {
                                isSheepTouchable = true
                                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                                sheep.removeFromParent()
                                sheepArrayLeft.removeAll { $0 == sheep }
                            }
                            sheep.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                            sheep.zPosition = 2
                            let move = SKAction.moveTo(x: position.x + frame.width / 2, duration: 2)
                            isSheepTouchable = false
                            sheepArrayLeft.removeAll { $0 == sheep }
                            sheep.run(SKAction.sequence([SKAction.group([scale, move]), bumpEnd]))
                            return
                        }

                        playFallAnimation(for: sheep)
                    }
                } else {
                    end = SKAction.run { [self] in
                        sheep.removeAllActions()
                        sheepArrayLeft.append(sheep)
                        changeGamePoint()
                        playFallAnimation(for: sheep)
                    }
                }

                periousTime = currentTime
                sheep.run(SKAction.group([SKAction.sequence([up, upEnd, down, end]), horz]))
                break
            }
        }

        touching = false
    }

    private func playFallAnimation(for sheep: SKSpriteNode) {
        let textures = ["sheep_faildown01", "sheep_faildown02", "sheep_faildown03"].map { SKTexture(imageNamed: $0) }
        let fall = SKAction.animate(with: textures, timePerFrame: 0.1)
        let end = SKAction.run { [self] in
            trimSheepLeft()
            sheepWalkL(sheep)
        }
        sheep.run(SKAction.sequence([SKAction.repeat(fall, count: 5), end]))
    }

    private func trimSheepLeft() {
        if sheepArrayLeft.count > sheepLeftMax, let removeSheep = sheepArrayLeft.first {
            removeSheep.removeAllActions()
            sheepArrayLeft.removeFirst()
            removeSheep.xScale = 1
            let move = SKAction.moveTo(x: -removeSheep.size.width, duration: 2)
            let end = SKAction.removeFromParent()
            removeSheep.run(SKAction.sequence([move, end]))
        }
    }

    func sheepWalkL(_ sheep: SKSpriteNode) {
        let x = CGFloat(Int.random(in: -80...80))
        let y = CGFloat(Int.random(in: -40...40))

        var newX = sheep.position.x + x
        var newY = sheep.position.y + y

        newX = max(sheep.size.width / 2, min(bar.position.x - sheep.size.width, newX))
        newY = max(sheep.size.height / 2, min(CGFloat(barHeight) - sheep.size.height, newY))

        sheep.xScale = x > 0 ? -1 : 1

        let textures = ["sheep_mimi01", "sheep_mimi02", "sheep_mimi03"].map { SKTexture(imageNamed: $0) }
        let animation = SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: 0.3))

        let delay = SKAction.wait(forDuration: 1.0)
        let randomWalk = SKAction.run { [weak self] in self?.sheepWalkL(sheep) }
        let end = SKAction.run {
            sheep.removeAllActions()
            sheep.texture = SKTexture(imageNamed: "sheep1")
            sheep.run(SKAction.sequence([delay, randomWalk]))
        }

        let move = SKAction.move(to: CGPoint(x: newX, y: newY), duration: 2)
        sheep.run(SKAction.group([SKAction.sequence([move, end]), animation]))
    }

    func sheepWalkR(_ sheep: SKSpriteNode) {
        let x = CGFloat(Int.random(in: -80...80))
        let y = CGFloat(Int.random(in: -40...40))

        var newX = sheep.position.x + x
        var newY = sheep.position.y + y

        newX = max(bar.position.x + bar.size.width, min(frame.width - sheep.size.width, newX))
        newY = max(sheep.size.height / 2, min(CGFloat(barHeight) - sheep.size.height, newY))

        sheep.xScale = x > 0 ? -1 : 1

        let textures = ["sheep1", "sheep2", "sheep3"].map { SKTexture(imageNamed: $0) }
        let animation = SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: 0.3))

        let delay = SKAction.wait(forDuration: 1.0)
        let randomWalk = SKAction.run { [weak self] in self?.sheepWalkR(sheep) }
        let end = SKAction.run {
            sheep.removeAllActions()
            sheep.texture = SKTexture(imageNamed: "sheep1")
            sheep.run(SKAction.sequence([delay, randomWalk]))
        }

        let move = SKAction.move(to: CGPoint(x: newX, y: newY), duration: 2)
        sheep.run(SKAction.group([SKAction.sequence([move, end]), animation]))
    }

    func getTimeTexture(_ time: Int) -> SKTexture {
        return TextureHelper.timeTextures()[time % 10]
    }
    
    func changeGamePoint() {
        sheepGameScore += 1

        gamePointSingleNode.texture = getTimeTexture(sheepGameScore % 10)
        gamePointTenNode.texture = getTimeTexture((sheepGameScore / 10) % 10)
        gamePointHunNode.texture = getTimeTexture((sheepGameScore / 100) % 10)
        gamePointTHUNode.texture = getTimeTexture((sheepGameScore / 1000) % 10)
    }
    
    func createSheep() -> SKSpriteNode {
        let randomX = CGFloat(arc4random_uniform(UInt32(self.frame.width / 2))) + bar.position.x + bar.size.width
        let randomY = CGFloat(arc4random_uniform(UInt32(self.frame.height / 2))) + 30

        let sheep = SKSpriteNode(imageNamed: "sheep1")
        sheep.size = CGSize(width: 70, height: 70)
        sheep.position = CGPoint(x: self.frame.width, y: randomY)

        let moveAction = SKAction.move(to: CGPoint(x: randomX, y: randomY), duration: 3)
        let textures = ["sheep1", "sheep2", "sheep3"].map { SKTexture(imageNamed: $0) }
        let animation = SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: 0.3))

        let endAction = SKAction.run { [weak self, weak sheep] in
            guard let self = self, let sheep = sheep else { return }
            sheep.removeAllActions()
            self.sheepWalkR(sheep)
        }

        sheep.run(SKAction.group([SKAction.sequence([moveAction, endAction]), animation]))
        return sheep
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameRun else { return }

        var timeSinceLast = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime

        if timeSinceLast > 1 {
            timeSinceLast = 1.0 / 60.0
            lastUpdateTimeInterval = currentTime
        }

        updateWithTimeSinceLastUpdate(timeSinceLast)
    }

    func updateWithTimeSinceLastUpdate(_ timeSinceLast: TimeInterval) {
        lastSpawnTimeInterval += timeSinceLast
        if lastSpawnTimeInterval > 0.5 {
            lastSpawnTimeInterval = 0
            ccount = (ccount + 1) % 10
        }
    }
}
