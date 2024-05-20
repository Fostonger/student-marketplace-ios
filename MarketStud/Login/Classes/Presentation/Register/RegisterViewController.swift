import UIKit

protocol RegisterView: AnyObject {
    func configure(with model: RegisterModel)
    func showLoading()
    func hideLoading()
    func showError(message: String)
    func showSuccess()
}

final class RegisterViewController: UIViewController, RegisterView {
    private var presenter: RegisterPresenter!
    
    private let nameTextField = UITextField()
    private let familyNameTextField = UITextField()
    private let loginTextField = UITextField()
    private let passwordTextField = UITextField()
    private let registerButton = UIButton()
    private let loadingIndicator = UIActivityIndicatorView()
    
    init(presenter: RegisterPresenter!) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        nameTextField.placeholder = "Name"
        familyNameTextField.placeholder = "Family Name"
        loginTextField.placeholder = "Login"
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        
        registerButton.setTitle("Register", for: .normal)
        registerButton.backgroundColor = .systemBlue
        registerButton.layer.cornerRadius = 5
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        
        loadingIndicator.style = .large
        loadingIndicator.hidesWhenStopped = true
        
        let stackView = UIStackView(arrangedSubviews: [nameTextField, familyNameTextField, loginTextField, passwordTextField, registerButton, loadingIndicator])
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
    
    @objc private func registerButtonTapped() {
        let user = RegisterUser(
            name: nameTextField.text ?? "",
            familyName: familyNameTextField.text ?? "",
            username: loginTextField.text ?? ""
        )
        let model = RegisterModel(
            user: user,
            password: passwordTextField.text ?? ""
        )
        presenter.registerUser(with: model)
    }
    
    // MARK: - RegisterView Protocol
    
    func configure(with model: RegisterModel) {
        nameTextField.text = model.user.name
        familyNameTextField.text = model.user.familyName
        loginTextField.text = model.user.username
        passwordTextField.text = model.password
    }
    
    func showLoading() {
        loadingIndicator.startAnimating()
        registerButton.isEnabled = false
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
        registerButton.isEnabled = true
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showSuccess() {
        let alert = UIAlertController(title: "Success", message: "Registration successful!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
