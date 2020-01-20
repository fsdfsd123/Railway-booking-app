//
//  SeatMapSceneView.swift
//  Shinkansen 3D Seat Booking Prototype
//
//  Created by Virakri Jinangkul on 6/6/19.
//  Copyright © 2019 Virakri Jinangkul. All rights reserved.
//

import UIKit
import SceneKit

protocol SeatMapSceneViewDelegate: AnyObject {
    func sceneViewDidPanFurtherUpperBoundLimit(by offset: CGPoint)
    func sceneView(sceneView: SeatMapSceneView, didSelected reservableEntity: ReservableEntity)
}

extension SeatMapSceneViewDelegate {
    func sceneViewDidPanFurtherUpperBoundLimit(by offset: CGPoint) { }
    func sceneView(sceneView: SeatMapSceneView, didSelected reservableEntity: ReservableEntity) {}
}

class SeatMapSceneView: SCNView {
    
    private let lightFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    weak var seatMapDelegate: SeatMapSceneViewDelegate?
    
    private var bottomOffset: CGFloat = 0
    
    /// The main node that contains all content which is repositioned according to the vertical pan gesture.
    private var contentNode: SCNNode! = SCNNode()
    
    private var stationDirectionTextNode: SCNNode! = SCNNode()
    
    private var cameraNode: CameraNode! = CameraNode()
    
    private var hitTestPositionWhenTouchBegan: SCNVector3?
    
    private var contentNodePositionWhenTouchBegan: SCNVector3?
    
    private var loadingActivityIndicatorView: UIView! = UIView()
    
    private var centerScreenZ: Float = 0
    
    private enum SeatNavigationState: String {
        case top
        case bottom
        case hide
    }
    
    private var seatNavigationState: SeatNavigationState = .hide {
        didSet {
            if seatNavigationState != oldValue {
                DispatchQueue.main.async { [weak self] in
                    switch self?.seatNavigationState ?? .hide {
                    case .top:
                        self?.addHeadsUpBadgeControl(withMessage: "↑ Your \(self?.selectedSeatNode?.reservableEntity?.name ?? "selected") seat is up there.",
                            bitMask: 1 << 1)
                    case .bottom:
                        self?.addHeadsUpBadgeControl(withMessage: "↓ Your \(self?.selectedSeatNode?.reservableEntity?.name ?? "selected") seat is down there.",
                            bitMask: 1 << 1)
                    case .hide:
                        self?.removeHeadsUpBadgeControl(animated: true, bitMask: 1 << 1)
                    }
                }
            }
        }
    }
    
    private var currectContentNodePosition: SCNVector3? {
        didSet {
            setCurrectContentNodePosition(
                currectContentNodePosition: currectContentNodePosition,
                oldValue: oldValue
            )
            if centerScreenZ == 0 {
                centerScreenZ = positionOfFloorHitTest(.init(x: 0, y: frame.midY))?.z ?? 0
            }
            if let selected = selectedSeatNode, let current = currectContentNodePosition?.z, centerScreenZ != 0 {
                if selected.position.z > centerScreenZ - current + 3 {
                    seatNavigationState = .bottom
                } else if selected.position.z < centerScreenZ - current - 4 {
                    seatNavigationState = .top
                }else{
                    seatNavigationState = .hide
                }
            }else{
                seatNavigationState = .hide
            }
        }
    }
    
    private var highlightedSeatNodes = Set<SeatNode>() {
        didSet {
            oldValue.subtracting(highlightedSeatNodes).forEach { $0.isHighlighted = false }
            highlightedSeatNodes.subtracting(oldValue).forEach {
                $0.isHighlighted = true
            }
        }
    }
    
    private weak var selectedSeatNode: SeatNode? {
        didSet {
            oldValue?.isSelected = false
            selectedSeatNode?.isSelected = true
            if let reservableEntity = selectedSeatNode?.reservableEntity {
                seatMapDelegate?.sceneView(sceneView: self, didSelected: reservableEntity)
                
                // Make sure that the seat isn't the same one before showing the message
                if oldValue != selectedSeatNode {
                    
                    let message = "Seat \(reservableEntity.name) in \(reservableEntity.carNumber.lowercased()) has been selected."
                    
                    addHeadsUpBadgeControl(withMessage: message,
                                           delayUntilRemoved: 4,
                                           bitMask: 1 << 0)
                }
                
                // Activate Impact
                lightFeedbackGenerator.impactOccurred()
            }
            if let selectedSeat = selectedSeatNode {
                animateContentNodeToZPosition(of: selectedSeat.position.z)
            }
        }
    }
    
    var perspectiveVelocity: Float?
    
    var contentZPositionLimit: ClosedRange<Float> = 0...1
    
    // MARK: Initialzer & Setup
    init() {
        super.init(frame: .zero, options: nil)
        setupView()
        setupScene()
        setupInteraction()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// View setup
    private func setupView() {
        backgroundColor = .clear
        
        /// Set Antialiasing Mode depending on the density of the pixels, so if the screen is 3X, the view will use `multisampling2X` otherwise it will use `multisampling4X`
        antialiasingMode = UIScreen.main.scale > 2 ?
            .multisampling2X : .multisampling4X
        
        /// Setup Loading Activity Indicator
        loadingActivityIndicatorView.backgroundColor = currentColorTheme.componentColor.cardBackground
        let indicatorView = UIActivityIndicatorView(style: .whiteLarge)
        indicatorView.color = currentColorTheme.componentColor.secondaryText
        indicatorView.startAnimating()
        loadingActivityIndicatorView
            .addSubview(indicatorView,
                        withConstaintEquals: .centerSafeArea,
                        insetsConstant: .init(bottom: 24))
        addSubview(loadingActivityIndicatorView, withConstaintEquals: .edges)
        
        preservesSuperviewLayoutMargins = true
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        /// Add visual effect
        superview?.addMotionEffect(TiltNodeMotionEffect(node: cameraNode))
    }
    
    // MARK: Scene setup
    private func setupScene() {
    
        let hitTestFloorNode = HitTestFloorNode()
        
        let scene = SCNScene()
        scene.background.contents = currentColorTheme.componentColor.cardBackground
        
        currectContentNodePosition = contentNode.position
        
        scene.rootNode.addChildNode(hitTestFloorNode)
        scene.rootNode.addChildNode(contentNode)
        scene.rootNode.addChildNode(cameraNode)
        
        self.scene = scene
    }
    
    private func placeStaticNodes(using transformedModelEntities: [TransformedModelEntity],
                                  isEnabled: Bool = true) {
        let staticNode = SCNNode()
        
        // Place static nodes
        transformedModelEntities.compactMap({
            if let node: StaticNode = NodeFactory.shared?.create(name: $0.modelEntity) {
                node.transformedModelEntity = $0
                node.isEnabled = isEnabled
                return node
            }
            return nil
        }).forEach {
            staticNode.addChildNode($0)
        }
        DispatchQueue.main.async { [weak self] in
            self?.contentNode?.addChildNode(staticNode)
        }
    }
    
    private func playInitialAnimation() {
        DispatchQueue.main.async { [weak self] in
            guard let contentZPositionLimit = self?.contentZPositionLimit else { return }
            /// Play initial Animation
            self?.currectContentNodePosition?.z = contentZPositionLimit.lowerBound
            let duration: TimeInterval = TimeInterval(abs(contentZPositionLimit.upperBound) - abs(contentZPositionLimit.lowerBound)) / 100 + 0.5
            SceneKitAnimator
                .animateWithDuration(duration: duration,
                                     timingFunction: .explodingEaseOut,
                                     animations: {
                                        self?.currectContentNodePosition?.z =
                                            (contentZPositionLimit.lowerBound * 2 +
                                                contentZPositionLimit.upperBound) / 3
                })
        }
    }
    
    deinit {
        // Try to inturrupt and remove model load operation
        workItems.forEach { $0.cancel() }
        workItems.removeAll()
    }
    
    var workItems: [DispatchWorkItem] = []
    
    private let currentEntityQueue = DispatchQueue(label: "Current Entity Placing Queue", qos: .utility)
    private let otherEntityQueue = DispatchQueue(label: "Placing Object Queue", qos: .background)
    
    /// Place seat to content node (expensive process)
    /// - Parameter factory: NodeFactory object
    /// - Parameter seatClassEntity: Seat class data
    /// - Parameter isCurrentEntity: To consider priority to load
    private func placeSeatClassNodes(seatClassEntity: SeatClassEntity,
                                     isCurrentEntity: Bool) {
        var workItem: DispatchWorkItem!
        weak var seatClassEntity = seatClassEntity
        workItem = DispatchWorkItem { [weak self] in
            guard !workItem.isCancelled else { return }
            // Generate all interactible nodes with transform values
            let containerNode = SCNNode()
            containerNode.name = seatClassEntity?.name
            let nodes: [SeatNode] = seatClassEntity?.reservableEntities.compactMap({
                guard !workItem.isCancelled else {
                    return nil
                }
                if let node: SeatNode = NodeFactory.shared?.create(name: $0.transformedModelEntity.modelEntity) {
                    node.reservableEntity = $0
                    // Assign Enabled state of interactible nodes
                    node.isEnabled = $0.isAvailable && isCurrentEntity
                    return node
                }
                /// Show Error node
                let node = PlaceholderSeatNode()
                node.reservableEntity = $0
                return node
            }) ?? []
            nodes.forEach { node in
                if !workItem.isCancelled {
                    containerNode.addChildNode(node)
                }
            }
            // Try to inturrupt when process did cancelled
            guard !workItem.isCancelled else { return }
            self?.placeStaticNodes(using: seatClassEntity?.transformedModelEntities ?? [],
                                   isEnabled: isCurrentEntity)
            DispatchQueue.main.async {
                // Add bunch of nodes to contentNode
                self?.contentNode?.addChildNode(containerNode)
                // When current entity is loaded, will remove indicator view
                if isCurrentEntity {
                    self?.playInitialAnimation()
                    self?.loadingActivityIndicatorView?.removeFromSuperview()
                    self?.alpha = 0
                    let duration: TimeInterval = TimeInterval(abs(self?.contentZPositionLimit.upperBound ?? 0) - abs(self?.contentZPositionLimit.lowerBound ?? 0)) / 100 + 0.5
                    UIView.animate(withDuration: duration, animations: {
                        self?.alpha = 1
                    })
                }
            }
        }
        
        (isCurrentEntity ? currentEntityQueue : otherEntityQueue).async(execute: workItem)
        workItems.append(workItem)
    
    }
    
    public func setupContent(seatMap: SeatMap,
                             currentEntity: SeatClassEntity,
                             fromStation: String?,
                             toStation: String?) {
        
        setupGlobalStaticContent(seatMap: seatMap)
        
        var seatClassEntities = seatMap.seatClassEntities
        
        // Reorder to have current seatClassEnity to be first memeber of the array
        if let index = seatClassEntities.firstIndex(where: { $0 === currentEntity }) {
            seatClassEntities.remove(at: index)
            seatClassEntities.insert(currentEntity, at: 0)
        }
        
        seatClassEntities.forEach {
            let isCurrentEntity = $0 === currentEntity
            
            if isCurrentEntity {
                // Set Seat Range
                contentZPositionLimit = $0
                    .viewableRange
                    .lowerBound.z...$0
                        .viewableRange
                        .upperBound.z
                
                // Set origin of the content to be center between lowerBound and upperbound
                currectContentNodePosition?.z =
                    ($0.viewableRange.lowerBound.z +
                        $0.viewableRange.upperBound.z) / 2
            }
            
            setupSeatClassContent(seatClassEntity: $0,
                                  isCurrentEntity: isCurrentEntity)
        }
        
        seatMap.transformedTextModelEntities.forEach {
            contentNode.addChildNode($0)
        }
        
        setupStationDirectionLabelNode(withFromStation: fromStation,
                                       toStation: toStation)
    }
    
    private func setupStationDirectionLabelNode(withFromStation fromStation: String?,
                                                toStation: String?) {
        let stationDirectionText = "\(toStation != nil ? "← \(toStation ?? "")" : "")\(fromStation != nil ? "     \(fromStation ?? "") →" : "")"
        stationDirectionTextNode = TextNode(text: stationDirectionText,
                                            font: .systemFont(ofSize: 0.5,
                                                              weight: .light),
                                            textAlignment: .right,
                                            color: currentColorTheme.componentColor.secondaryText)
        stationDirectionTextNode.position = SCNVector3(-3.15, 1.2, -13)
        stationDirectionTextNode.eulerAngles.y = .pi / 2
        
        self.scene?.rootNode.addChildNode(stationDirectionTextNode)
    }
    
    private func setupGlobalStaticContent(seatMap: SeatMap) {
        
        if let factory = NodeFactory.shared {
            let onComplete: () -> Void = { [weak self] in
                self?.placeStaticNodes(using: seatMap.transformedModelEntities)
            }
            if factory.isLoaded {
                DispatchQueue.global(qos: .background).async(execute: onComplete)
            }else{
                factory.onComplete(callback: onComplete)
            }
        }else{
            fatalError("NodeFactory is not defined before used")
        }
    }
    
    private func setupSeatClassContent(seatClassEntity: SeatClassEntity,
                                       isCurrentEntity: Bool = true) {
        
        if let factory = NodeFactory.shared {
            let onComplete: () -> Void = { [weak self] in
                self?.placeSeatClassNodes(seatClassEntity: seatClassEntity,
                                          isCurrentEntity: isCurrentEntity)
            }
            if factory.isLoaded {
                DispatchQueue.global(qos: .background).async(execute: onComplete)
            }else{
                factory.onComplete(callback: onComplete)
            }
        }else{
            fatalError("NodeFactory is not defined before used")
        }
    }
    
    private func setupInteraction() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureDidPan))
        panGesture.maximumNumberOfTouches = 1
        addGestureRecognizer(panGesture)
    }
    
    // MARK: State Change / Update
    
    private func setCurrectContentNodePosition(currectContentNodePosition: SCNVector3?, oldValue: SCNVector3?) {
        contentNode.position = currectContentNodePosition ?? contentNode.position
        
        guard let currectContentNodePosition = currectContentNodePosition, let oldValue = oldValue else { return }
        perspectiveVelocity = (currectContentNodePosition.z - oldValue.z) / (1 / 60)
        
        // Conform to the delegate
        let upperBoundLimitOffsetY: CGFloat = CGFloat(contentZPositionLimit.upperBound - currectContentNodePosition.z)
        seatMapDelegate?
            .sceneViewDidPanFurtherUpperBoundLimit(by: CGPoint(x: 0,
                                                               y: upperBoundLimitOffsetY / 0.04))
    }
    
    // MARK: Gestures
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        contentNode.removeAction(forKey: "panDrift")
        for node in filterReservationNodeFrom(touches) {
            highlightedSeatNodes.insert(node)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if highlightedSeatNodes.count > 0 {
            highlightedSeatNodes.removeAll()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        touches.compactMap ({ touch in
            highlightedSeatNodes.first { $0.touch == touch }
        }).forEach { node in
            selectedSeatNode = node
            highlightedSeatNodes.remove(node)
        }
    }
    
    @objc private func panGestureDidPan(_ sender: UIPanGestureRecognizer) {
        
        let location = sender.location(in: self)
        
        switch sender.state {
            
        case .began:
            hitTestPositionWhenTouchBegan = positionOfFloorHitTest(location)
            contentNodePositionWhenTouchBegan = contentNode.position
            
        case .changed:
            let hitTestPositionWhereCurrentTouch = positionOfFloorHitTest(location)
            
            if let hitTestPositionWhereTouchBegan = hitTestPositionWhenTouchBegan,
                let hitTestPositionWhereCurrentTouch = hitTestPositionWhereCurrentTouch,
                let contentNodePositionWhereTouchBegan = contentNodePositionWhenTouchBegan {
                
                let zPosition = zPositionClamp(hitTestPositionWhereCurrentTouch.z - hitTestPositionWhereTouchBegan.z + contentNodePositionWhereTouchBegan.z)
                self.currectContentNodePosition?.z = zPosition
            }
            
        case .ended:
            var currentTime: CGFloat = 0
            var currentVelocity = CGPoint(x: 0, y: CGFloat(perspectiveVelocity ?? 0))
            
            let driftAction = SCNAction
                .customAction(duration: DecayFunction
                    .timeToHalt(velocity: currentVelocity), action: {
                        [weak self] (node, elapsedTime) in
                        guard let self = self else { return }
                        let newStep = DecayFunction
                            .step(timeElapsed: CFTimeInterval(elapsedTime - currentTime),
                                  velocity: currentVelocity)
                        
                        let yDisplacment = newStep.displacement.y
                        
                        let newZPosition = self.contentNode.position.z + Float(yDisplacment)
                        
                        self.currectContentNodePosition?.z = (newZPosition + self.zPositionClamp(newZPosition)) / 2
                        
                        self.currectContentNodePosition = self.contentNode.position
                        
                        currentVelocity = newStep.velocity
                        currentTime = elapsedTime
                })
            
            contentNode.runAction(driftAction,
                                  forKey: "panDrift",
                                  completionHandler:{ [weak self] in
                                    guard let currentZ = self?.currectContentNodePosition?.z,
                                        let contentZPositionLimit = self?.contentZPositionLimit else { return }
                                    // reset the position of the content if it goes beyond the position limit after the panDrift animation
                                    self?.currectContentNodePosition?.z = max(min(currentZ, contentZPositionLimit.upperBound), contentZPositionLimit.lowerBound)
            })
            
            
        default:
            break
        }
    }
    
    @objc private func headsUpbadgeControlDidTouch(_ sender: HeadsUpBadgeControl) {
        if let selectedSeat = selectedSeatNode {
            animateContentNodeToZPosition(of: selectedSeat.position.z)
        }
    }
    
    // MARK: Utility & Helper
    
    /// Recursive find parent node that be `ReservableNode` class
    /// - Parameter node: Target node to find
    func findParent(of node: SCNNode?) -> SeatNode? {
        guard let node = node else {
            return nil
        }
        if let node = node as? SeatNode {
            return node
        }
        return findParent(of: node.parent)
    }
    
    /// Get nodes from touches position
    /// - Parameter touches: Set of touch to determine
    private func filterReservationNodeFrom(_ touches: Set<UITouch>) -> [SeatNode] {
        return touches.compactMap { touch in
            let firstHitTestResult = hitTest(touch.location(in: self),
                                             options: [.categoryBitMask: SeatNode.defaultBitMask]).first
            if let node = firstHitTestResult?.node,
                let parent = findParent(of: node),
                parent.isEnabled {
                parent.touch = touch
                return parent
            }
            return nil
        }
    }
    
    private func zPositionClamp(_ value: Float) -> Float {
        let trimmedMaxValue = value > contentZPositionLimit.upperBound ? contentZPositionLimit.upperBound * (1 + log10(value/contentZPositionLimit.upperBound)) : value
        
        return value < contentZPositionLimit.lowerBound ? contentZPositionLimit.lowerBound * (1 + log10( trimmedMaxValue  / contentZPositionLimit.lowerBound )) : trimmedMaxValue
    }
    
    private func positionOfFloorHitTest(_ point: CGPoint) -> SCNVector3? {
        let hitTests = hitTest(point, options: [.categoryBitMask : 1 << 1])
        return hitTests.first?.worldCoordinates
    }
    
    private func animateContentNodeToZPosition(of zPosition: Float) {
        contentNode.removeAction(forKey: "panDrift")
        let center = positionOfFloorHitTest(.init(x: 0, y: frame.midY))?.z ?? 0
        SceneKitAnimator.animateWithDuration(
            duration: 0.35 * 2,
            timingFunction: .easeOut,
            animations: {
                currectContentNodePosition?.z = -zPosition + center
        })
    }
}

extension SeatMapSceneView {
    func addHeadsUpBadgeControl(withMessage message: String,
                                animated: Bool = true,
                                delayUntilRemoved: TimeInterval = 0,
                                bitMask: Int = 1 << 0,
                                completion: ((Bool)->())? = nil) {
        
            /// Remove all badgeControls first
            removeHeadsUpBadgeControl(animated: false)
            /// Setup headsUpBadgeControl
            let headsUpBadgeControl = HeadsUpBadgeControl()
            headsUpBadgeControl.tag = bitMask
            addSubview(headsUpBadgeControl,
                             withConstaintEquals: [.topMargin, .centerHorizontal])
            headsUpBadgeControl
                .addTarget(self,
                           action: #selector(headsUpbadgeControlDidTouch(_:)),
                           for: .touchUpInside)
        headsUpBadgeControl
            .setupContent(message: message,
                          animated: animated,
                          delay: 0,
                          completion: { finished in
                            if let completion = completion {
                                completion(finished)
                            }
                            if delayUntilRemoved > 0 {
                                headsUpBadgeControl.dismiss(animated: animated,
                                                            delay: delayUntilRemoved,
                                                            removeWhenComplete: true)
                            }
            })
        }
        
        func removeHeadsUpBadgeControl(animated: Bool = true,
                                   bitMask: Int? = nil,
                                   completion: ((Bool)->())? = nil) {
        subviews.forEach {
            guard let headsUpBadgeControl = $0 as? HeadsUpBadgeControl else { return }
            let removeHeadsUpBadgeAction = {
                headsUpBadgeControl.dismiss(animated: animated,
                                            removeWhenComplete: true)
            }
            if bitMask != nil {
                if $0.tag == bitMask { removeHeadsUpBadgeAction() }
            } else { removeHeadsUpBadgeAction() }
        }
    }
}
