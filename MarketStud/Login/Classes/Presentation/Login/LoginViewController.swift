import UIKit

protocol LoginView: AnyObject {
    func configure(with model: LoginModel)
    func showLoading()
    func hideLoading()
    func showError(message: String)
    func showSuccess()
}

final class LoginViewController: UIViewController, LoginView {
    var presenter: LoginPresenter!
    
    private let loginTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton()
    private let registerButton = UIButton()
    private let loadingIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        loginTextField.placeholder = "Login"
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        
        loginButton.setTitle("Login", for: .normal)
        loginButton.backgroundColor = .systemBlue
        loginButton.layer.cornerRadius = 5
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        registerButton.setTitle("Register", for: .normal)
        registerButton.backgroundColor = .systemGreen
        registerButton.layer.cornerRadius = 5
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        
        loadingIndicator.style = .large
        loadingIndicator.hidesWhenStopped = true
        
        let stackView = UIStackView(arrangedSubviews: [loginTextField, passwordTextField, loginButton, registerButton, loadingIndicator])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func loginButtonTapped() {
        let model = LoginModel(
            user: LoginUser(username: loginTextField.text ?? ""),
            password: passwordTextField.text ?? ""
        )
        presenter.loginUser(with: model)
    }
    
    @objc private func registerButtonTapped() {
        presenter.navigateToRegister()
    }
    
    // MARK: - LoginView Protocol
    
    func configure(with model: LoginModel) {
        loginTextField.text = model.user.username
        passwordTextField.text = model.password
    }
    
    func showLoading() {
        loadingIndicator.startAnimating()
        loginButton.isEnabled = false
        registerButton.isEnabled = false
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
        loginButton.isEnabled = true
        registerButton.isEnabled = true
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showSuccess() {
        let alert = UIAlertController(title: "Success", message: "Login successful!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
