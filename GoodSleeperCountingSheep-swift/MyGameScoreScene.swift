//
//  MyGameScoreScene.swift
//  GoodSleeperCountingSheep-swift
//
//  Created by Phil on 2025/3/29.
//

import SpriteKit

class MyGameScoreScene: SKScene {

    weak var sceneTransitionDelegate: ReturnToMySceneDelegate?
    var periousScene: SKScene?
    var sheepGameScore: Int = 0
    var updateSheepGameScore: Bool = false

    private var gamePointSingleNode: SKSpriteNode!
    private var gamePointTenNode: SKSpriteNode!
    private var gamePointHunNode: SKSpriteNode!
    private var gamePointTHUNode: SKSpriteNode!
    private var sheepSleepNode: SKSpriteNode!

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

        let cumulative = SKSpriteNode(imageNamed: "cumulative")
        cumulative.size = CGSize(width: 400, height: 80)
        cumulative.anchorPoint = CGPoint(x: 0, y: 0)
        cumulative.position = CGPoint(x: 0, y: self.size.height - cumulative.size.height - 50)
        addChild(cumulative)

        let textures = ["sheep_sleep1", "sheep_sleep2", "sheep_sleep3", "sheep_sleep4", "sheep_sleep5"].map { SKTexture(imageNamed: $0) }

        sheepSleepNode = SKSpriteNode(texture: textures[0])
        sheepSleepNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        sheepSleepNode.size = CGSize(width: size.width / 2, height: size.height * 3 / 4)
        sheepSleepNode.position = CGPoint(x: size.width * 3 / 4, y: size.height / 3)
        addChild(sheepSleepNode)

        let sleepAction = SKAction.animate(with: textures, timePerFrame: 0.3)
        sheepSleepNode.run(SKAction.repeatForever(sleepAction))
    }

    override func update(_ currentTime: TimeInterval) {
        if updateSheepGameScore {
            let gamePointNodeWH = 60
            let gamePointX = Int(self.size.width) / 3
            let gamePointY = Int(self.size.height) * 2 / 8

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

            updateSheepGameScore = false
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        (periousScene as? MyScene)?.showAdmob?()

        guard let view = self.view else { return }
        let gameOverScene = MyGameOverScene(size: view.frame.size)
        gameOverScene.scaleMode = self.scaleMode
        gameOverScene.periousScene = periousScene
        gameOverScene.sceneTransitionDelegate = sceneTransitionDelegate

        let transition = SKTransition.flipHorizontal(withDuration: 0.5)
        view.presentScene(gameOverScene, transition: transition)

        self.removeFromParent()
    }

    private func getTimeTexture(_ time: Int) -> SKTexture {
        let textures = TextureHelper.timeTextures()
        return textures[time % 10]
    }
}
