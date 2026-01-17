//
//  TerrainChunk.swift
//  HillClimbRacer
//
//  A single segment of terrain with visual shape and physics body.
//

import SpriteKit

class TerrainChunk: SKNode {

    // MARK: - Properties

    /// The starting X position of this chunk
    let startX: CGFloat

    /// The ending X position of this chunk
    let endX: CGFloat

    /// The visual shape node for the terrain
    private let shapeNode: SKShapeNode

    /// Points defining the top surface of the terrain
    let surfacePoints: [CGPoint]

    // MARK: - Initialization

    init(startX: CGFloat, points: [CGPoint], groundDepth: CGFloat = Constants.Terrain.groundDepth) {
        self.startX = startX
        self.endX = points.last?.x ?? startX
        self.surfacePoints = points

        // Create the terrain shape path
        let path = CGMutablePath()

        // Start at bottom-left corner
        path.move(to: CGPoint(x: points.first!.x, y: -groundDepth))

        // Draw surface points
        for point in points {
            path.addLine(to: point)
        }

        // Close the shape at bottom-right
        path.addLine(to: CGPoint(x: points.last!.x, y: -groundDepth))
        path.closeSubpath()

        // Create shape node
        shapeNode = SKShapeNode(path: path)
        shapeNode.fillColor = SKColor(red: 0.4, green: 0.26, blue: 0.13, alpha: 1.0)  // Brown
        shapeNode.strokeColor = SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)  // Green top
        shapeNode.lineWidth = 4
        shapeNode.zPosition = Constants.ZPosition.terrain

        super.init()

        addChild(shapeNode)
        setupPhysics(points: points)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupPhysics(points: [CGPoint]) {
        // Create edge chain from surface points for terrain collision
        var edgePoints = points

        // Create physics body from edge chain
        let edgePath = CGMutablePath()
        edgePath.move(to: edgePoints[0])
        for i in 1..<edgePoints.count {
            edgePath.addLine(to: edgePoints[i])
        }

        physicsBody = SKPhysicsBody(edgeChainFrom: edgePath)
        physicsBody?.categoryBitMask = PhysicsCategory.terrain
        physicsBody?.collisionBitMask = PhysicsCategory.wheel | PhysicsCategory.chassis
        physicsBody?.contactTestBitMask = PhysicsCategory.chassis

        physicsBody?.friction = 0.8
        physicsBody?.restitution = 0.1
        physicsBody?.isDynamic = false
    }

    // MARK: - Public Methods

    /// Get the Y position of the terrain surface at a given X position
    func surfaceY(at x: CGFloat) -> CGFloat? {
        guard x >= startX, x <= endX else { return nil }

        // Find the two points surrounding this X position
        for i in 0..<(surfacePoints.count - 1) {
            let p1 = surfacePoints[i]
            let p2 = surfacePoints[i + 1]

            if x >= p1.x && x <= p2.x {
                // Linear interpolation between points
                let t = (x - p1.x) / (p2.x - p1.x)
                return p1.y + t * (p2.y - p1.y)
            }
        }

        return nil
    }
}
