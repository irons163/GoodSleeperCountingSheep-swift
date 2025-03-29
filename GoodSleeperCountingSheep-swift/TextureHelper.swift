//
//  TextureHelper.swift
//  GoodSleeperCountingSheep-swift
//
//  Created by Phil on 2025/3/29.
//

import SpriteKit
import UIKit

class TextureHelper {

    private static var hand1Textures: [SKTexture] = []
    private static var hand2Textures: [SKTexture] = []
    private static var hand3Textures: [SKTexture] = []

    private static var cat1Textures: [SKTexture] = []
    private static var cat2Textures: [SKTexture] = []
    private static var cat3Textures: [SKTexture] = []
    private static var cat4Textures: [SKTexture] = []
    private static var cat5Textures: [SKTexture] = []

    private static var hamsterInjure: SKTexture = SKTexture(imageNamed: "hamster_injure")
    private static var bgTexturesArray: [SKTexture] = (1...15).map { SKTexture(imageNamed: "bg\($0 < 10 ? "0\($0)" : "\($0)").jpg") }
    private static var timeTexturesArray: [SKTexture] = [
        SKTexture(imageNamed: "score0"),
        SKTexture(imageNamed: "score1"),
        SKTexture(imageNamed: "score2"),
        SKTexture(imageNamed: "score3"),
        SKTexture(imageNamed: "score4"),
        SKTexture(imageNamed: "score5"),
        SKTexture(imageNamed: "score6"),
        SKTexture(imageNamed: "score7"),
        SKTexture(imageNamed: "score8"),
        SKTexture(imageNamed: "score9"),
        SKTexture(imageNamed: "dot")
    ]

    private static var timeImagesArray: [UIImage] = [
        UIImage(named: "score0"), UIImage(named: "score1"), UIImage(named: "score2"),
        UIImage(named: "score3"), UIImage(named: "score4"), UIImage(named: "score5"),
        UIImage(named: "score6"), UIImage(named: "score7"), UIImage(named: "score8"),
        UIImage(named: "score9")
    ].compactMap { $0 }

    static func initCatTextures() {
        cat1Textures = (1...4).map { SKTexture(imageNamed: "cat01_\($0)") }
        cat2Textures = (1...4).map { SKTexture(imageNamed: "cat02_\($0)") }
        cat3Textures = (1...4).map { SKTexture(imageNamed: "cat03_\($0)") }
        cat4Textures = (1...4).map { SKTexture(imageNamed: "cat04_\($0)") }
        cat5Textures = (1...4).map { SKTexture(imageNamed: "cat05_\($0)") }
    }

    static func initHandTextures(sourceRect: CGRect, rows: Int, cols: Int) {
        hand1Textures = getTextures(from: "hand1", sourceRect: sourceRect, rows: rows, cols: cols)
        hand2Textures = getTextures(from: "hand2", sourceRect: sourceRect, rows: rows, cols: cols)
        hand3Textures = getTextures(from: "hand3", sourceRect: sourceRect, rows: rows, cols: cols)
    }

    static func getTextures(from spriteSheet: String, sourceRect: CGRect, rows: Int, cols: Int) -> [SKTexture] {
        guard let image = UIImage(named: spriteSheet), let cgImage = image.cgImage else { return [] }
        let ssTexture = SKTexture(image: UIImage(cgImage: cgImage))
        ssTexture.filteringMode = .nearest

        var frames: [SKTexture] = []
        var sx = sourceRect.origin.x
        var sy = sourceRect.origin.y
        let sWidth = sourceRect.size.width
        let sHeight = sourceRect.size.height

        for i in 0..<(rows * cols) {
            let rect = CGRect(x: sx, y: sy, width: sWidth / ssTexture.size().width, height: sHeight / ssTexture.size().height)
            let texture = SKTexture(rect: rect, in: ssTexture)
            frames.append(texture)

            sx += sWidth / ssTexture.size().width
            if (i + 1) % cols == 0 {
                sx = sourceRect.origin.x
                sy += sHeight / ssTexture.size().height
            }
        }
        return frames
    }

    static func getTextures(from spriteSheet: String, sourceRect: CGRect, rows: Int, cols: Int, sequence: [Int]) -> [SKTexture] {
        let allFrames = getTextures(from: spriteSheet, sourceRect: sourceRect, rows: rows, cols: cols)
        return sequence.compactMap { allFrames[safe: $0] }
    }

    static func hand1() -> [SKTexture] { hand1Textures }
    static func hand2() -> [SKTexture] { hand2Textures }
    static func hand3() -> [SKTexture] { hand3Textures }

    static func cat1() -> [SKTexture] { cat1Textures }
    static func cat2() -> [SKTexture] { cat2Textures }
    static func cat3() -> [SKTexture] { cat3Textures }
    static func cat4() -> [SKTexture] { cat4Textures }
    static func cat5() -> [SKTexture] { cat5Textures }

    static func backgrounds() -> [SKTexture] { bgTexturesArray }
    static func hamsterInjureTexture() -> SKTexture? { hamsterInjure }
    static func timeTextures() -> [SKTexture] { timeTexturesArray }
    static func timeImages() -> [UIImage] { timeImagesArray }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
