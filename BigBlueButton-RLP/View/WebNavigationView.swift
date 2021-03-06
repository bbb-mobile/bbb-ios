import UIKit

protocol WebNavigationViewDelegate: AnyObject {
    func didTapBackBtn()
    func didTapForwardBtn()
    func didTapRefreshBtn()
}

enum Opacity: CGFloat {
    case enabled = 1.0
    case disabled = 0.3
}

class WebNavigationView: UIView {
    
    private static let spacing: CGFloat = 32
    weak var webNavigationDelegate: WebNavigationViewDelegate?
    private let stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = WebNavigationView.spacing
        return stackView
    }()
    
    private let backButton: UIButton = {
        let btn = UIButton(frame: .zero)
        let image = UIImage(systemName: "arrow.left")
        btn.setImage(image, for: .normal)
        return btn
    }()
    
    private let forwardButton: UIButton = {
        let btn = UIButton(frame: .zero)
        let image = UIImage(systemName: "arrow.right")
        btn.setImage(image, for: .normal)
        return btn
    }()
    
    private let refreshButton: UIButton = {
        let btn = UIButton(frame: .zero)
        let image = UIImage(systemName: "arrow.clockwise")
        btn.setImage(image, for: .normal)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .darkGray
        setupTargets()
        addSubviews()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(canGoBack: Bool, canGoForward: Bool) {
        interact(with: backButton, isEnabled: canGoBack)
        interact(with: forwardButton, isEnabled: canGoForward)
    }
    
    private func interact(with btn: UIButton, isEnabled: Bool) {
        btn.isUserInteractionEnabled = isEnabled
        btn.alpha = isEnabled ? Opacity.enabled.rawValue : Opacity.disabled.rawValue
    }
    
    private func setupTargets() {
        backButton.addTarget(self, action: #selector(didTapBackButton(_:)), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(didTapForwardButton(_:)), for: .touchUpInside)
        refreshButton.addTarget(self, action: #selector(didTapRefreshButton(_:)), for: .touchUpInside)
    }
    
    private func addSubviews() {
        stackView.addArrangedSubview(backButton)
        stackView.addArrangedSubview(forwardButton)
        stackView.addArrangedSubview(refreshButton)
    }
    
    private func layout() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stackView)
        
        stackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: Self.spacing).isActive = true
        stackView.rightAnchor.constraint(lessThanOrEqualTo: self.rightAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    @objc func didTapBackButton(_ button: UIButton) {
        webNavigationDelegate?.didTapBackBtn()
    }
    
    @objc func didTapForwardButton(_ button: UIButton) {
        webNavigationDelegate?.didTapForwardBtn()
    }
    
    @objc func didTapRefreshButton(_ button: UIButton) {
        webNavigationDelegate?.didTapRefreshBtn()
    }
}
