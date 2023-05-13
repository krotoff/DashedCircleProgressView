import UIKit.UIView

open class DashedCircleProgressView: UIView {

    // MARK: - Public types

    public struct Configuration {
        public let activeColor: UIColor
        public let trackColor: UIColor
        public let lineWidth: CGFloat
        public let minimalDashSpacing: Double
        /// Angle in radians (e.g: `2 * .pi`)
        public let startAngle: CGFloat
        /// Angle in radians (e.g: `2 * .pi`)
        public let endAngle: CGFloat

        public init(
            activeColor: UIColor,
            trackColor: UIColor,
            lineWidth: CGFloat,
            minimalDashSpacing: Double,
            startAngle: CGFloat,
            endAngle: CGFloat
        ) {
            self.activeColor = activeColor
            self.trackColor = trackColor
            self.lineWidth = lineWidth
            self.minimalDashSpacing = minimalDashSpacing
            self.startAngle = startAngle
            self.endAngle = endAngle
        }
    }

    // MARK: - Private properties

    private let configuration: Configuration

    private lazy var activeCircleLayer: CAShapeLayer = {
        let dashedCircle = CAShapeLayer()
        dashedCircle.strokeColor = configuration.activeColor.cgColor
        dashedCircle.fillColor = UIColor.clear.cgColor
        dashedCircle.lineWidth = configuration.lineWidth
        dashedCircle.lineJoin = .round
        dashedCircle.lineCap = .round

        return dashedCircle
    }()

    private lazy var trackingCircleLayer: CAShapeLayer = {
        let dashedCircle = CAShapeLayer()
        dashedCircle.strokeColor = configuration.trackColor.cgColor
        dashedCircle.fillColor = UIColor.clear.cgColor
        dashedCircle.lineWidth = configuration.lineWidth
        dashedCircle.lineJoin = .round
        dashedCircle.lineCap = .round

        return dashedCircle
    }()

    private var passedCount = 0
    private var totalCount = 1

    // MARK: - Init

    public init(configuration: Configuration) {
        self.configuration = configuration

        super.init(frame: .zero)

        setupUI()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        updateLayersIfPossible()
    }

    // MARK: - Public methods

    public func reset() {
        updateProgress(passed: 0, total: 1)
    }

    public func updateProgress(passed: Int, total: Int) {
        totalCount = max(total, 1)
        passedCount = min(max(passed, 0), totalCount)

        updateLayersIfPossible()
    }

    // MARK: - Private methods

    private func setupUI() {
        [trackingCircleLayer, activeCircleLayer].forEach(layer.addSublayer)
    }

    private func updateLayersIfPossible() {
        guard bounds.width > 0, bounds.height > 0 else { return }

        let angleDifference = configuration.endAngle - configuration.startAngle
        let angleSection = angleDifference / CGFloat(totalCount)
        let radius = bounds.width / 2
        let oneDash = Double(angleSection * radius)
        let space = configuration.minimalDashSpacing
        let dashLength = oneDash - space
        let pattern = [NSNumber(floatLiteral: dashLength), NSNumber(floatLiteral: space)]
        activeCircleLayer.lineDashPattern = pattern
        trackingCircleLayer.lineDashPattern = pattern

        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: radius, y: radius),
            radius: radius,
            startAngle: configuration.startAngle,
            endAngle: configuration.endAngle,
            clockwise: true
        )
        trackingCircleLayer.path = circlePath.cgPath

        let activeCirclePath = UIBezierPath(
            arcCenter: CGPoint(x: radius, y: radius),
            radius: radius,
            startAngle: configuration.startAngle,
            endAngle: angleSection * CGFloat(passedCount) + configuration.startAngle,
            clockwise: true
        )
        activeCircleLayer.path = activeCirclePath.cgPath
    }
}
