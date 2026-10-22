import UIKit

class ListViewController: UIViewController {
    
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    private var users: [SimplifiedUser] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupTitleLabel()
        setupTableView()
        setupLoadingIndicator()
        
        fetchUsers()
    }
    
    private func setupTitleLabel() {
        titleLabel.text = "Face Book"
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textColor = .systemPink
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 70),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
        
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        
        // tells the table view to automatically expand heights for the multi-line subtitle rows
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupLoadingIndicator() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    
    private func fetchUsers() {
        loadingIndicator.startAnimating()
        
        Task {
            let usersURL = URL(string: "https://dummyjson.com/users?limit=10")!
            let faceAPIURL = URL(string: "https://100k-faces.vercel.app/api/random-image")!
            
            do {
                // fetch the 10 User Profiles JSON text payload
                let (userData, _) = try await URLSession.shared.data(from: usersURL)
                struct Response: Decodable { let users: [SimplifiedUser] }
                let response = try JSONDecoder().decode(Response.self, from: userData)
                var temporaryUsers = response.users
                
                // fetch a unique random face API asset for each profile securely
                for index in 0..<temporaryUsers.count {
                    if let (faceData, _) = try? await URLSession.shared.data(from: faceAPIURL) {
                        temporaryUsers[index].loadedFaceImage = UIImage(data: faceData)
                    }
                }
                
                // update the UI once on the Main Thread
                await MainActor.run {
                    self.users = temporaryUsers
                    self.tableView.reloadData()
                    self.loadingIndicator.stopAnimating()
                }
                
            } catch {
                await MainActor.run { self.loadingIndicator.stopAnimating() }
                print("API Processing Error: \(error)")
            }
        }
    }


    
}

// MARK: - UITableViewDataSource
extension ListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "UserCell")
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.fullName
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = "Age: \(user.age) \n\(user.email)"
        
        if let explicitFace = user.loadedFaceImage {
            cell.imageView?.image = explicitFace
        } else {
            cell.imageView?.image = UIImage(systemName: "person.crop.circle")
        }
        
        if let imageView = cell.imageView {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 40),
                imageView.heightAnchor.constraint(equalToConstant: 40),
                imageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16)
            ])
            
            imageView.layer.cornerRadius = 20
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            
            if let textLabel = cell.textLabel {
                textLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    textLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
                    textLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 12),
                    textLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16)
                ])
            }
            
            if let detailLabel = cell.detailTextLabel {
                detailLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    detailLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
                    detailLabel.topAnchor.constraint(equalTo: cell.textLabel!.bottomAnchor, constant: 4),
                    detailLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -12),
                    detailLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16)
                ])
            }
            
        }
        
        //cell.separatorInset = UIEdgeInsets(top: 0, left: 68, bottom: 0, right: 0)
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
                
        return cell
    }
}





#Preview {
    let navController = UINavigationController(rootViewController: ListViewController())
    return navController
}
