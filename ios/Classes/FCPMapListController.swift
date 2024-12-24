//
//  FCPMapListController.swift
//  Pods
//
//  Created by dev on 18/12/24.
//

import UIKit

class FCPMapListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // Define your table view
    let tableView = UITableView(frame: .zero,style: .plain)
    
    let heightCell = 80.0
    
    // Định nghĩa nguồn dữ liệu cho table view
    var data: [FCPMapListModel]
    
    var heightBounds: Double
    
    // Khởi tạo tùy chỉnh nhận dữ liệu
    init(data: [FCPMapListModel], heightBounds: Double) {
        self.data = data
        self.heightBounds = heightBounds
        super.init(nibName: nil, bundle: nil)
    }
    
    // Khởi tạo bắt buộc từ `UIViewController`
    required init?(coder: NSCoder) {
        self.data = []
        self.heightBounds = UIScreen.main.bounds.size.width
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register the custom cell
        tableView.register(FCPMapListCell.self, forCellReuseIdentifier: "FCPMapListCell")
        // Setup table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = CGRect(x: 0, y: 0, width: 300, height: heightBounds)
        tableView.backgroundColor = UIColor.white
        tableView.contentInsetAdjustmentBehavior = .never
        view.addSubview(tableView)
    }
    
    // MARK: - Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FCPMapListCell", for: indexPath) as? FCPMapListCell else {
            return UITableViewCell()
        }
        let model = data[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.contentView.layoutMargins = .zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.separatorInset = UIEdgeInsets.zero
        cell.layer.borderWidth = .zero
        cell.layer.cornerRadius = .zero
        cell.layer.masksToBounds = true
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightCell
    }
}


class FCPMapListCell: UITableViewCell {
    let outerView = UIView()
    let firstSubview = UIView()
    let secondSubview = UIView()
    let thirdSubview = UIView()
    let informationSubview = UIView()
    let circleView = UIView()
    let topLabel = UILabel()
    let bottomLabel = UILabel()
    let totalPick = UILabel()
    let totalDrop = UILabel()
    let confirmUserPickDrop = UILabel()
    let viewIconPick = UIImageView()
    let viewIconDrop = UIImageView()
    let sizeIcon: Double = 16
    let marginTop: Double = 10
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layoutMargins = UIEdgeInsets.zero
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layoutMargins = UIEdgeInsets.zero
        setupViews()
    }
    
    override func prepareForReuse() {
       removeAllBorder(view: informationSubview)
    }
    
    func removeAllBorder(view: UIView) {
        view.layer.borderWidth = 0
        view.layer.borderColor = nil
    }

    func configure(with model: FCPMapListModel) {
        // circle view
        circleView.backgroundColor = model.getIsCheckIn() == true ? UIColor.systemGreen : UIColor.gray
        
        // time label
        topLabel.text = model.getTime() ?? "-"
        
        // address label
        bottomLabel.text = model.getAddress() ?? "-"
        
        // total pick
        totalPick.text = model.getUserPick() ?? "-"
        
        // total drop
        totalDrop.text = model.getUserDrop() ?? "-"
        
        // confrim user
        confirmUserPickDrop.text = model.getConfirmUser() ?? "-"
        confirmUserPickDrop.textColor = model.getIsConfirmUser() == true ? UIColor.systemGreen : UIColor.systemRed
        
        // Show/hide view
        if model.getIsShowUserPick() == false {
            totalPick.isHidden = true
            viewIconPick.isHidden = true
        } else {
            totalPick.isHidden = false
            viewIconPick.isHidden = false
        }
        
        if model.getIsShowUserDrop() == false {
            totalDrop.isHidden = true
            viewIconDrop.isHidden = true
        } else {
            totalDrop.isHidden = false
            viewIconDrop.isHidden = false
        }
        
        if model.getIsShowLabelUserConfirm() == false {
            confirmUserPickDrop.isHidden = true
        } else {
            confirmUserPickDrop.isHidden = false
        }
        
        // Show/hide border information view
        if model.getIsCurrentPoint() == true {
            informationSubview.layer.borderWidth = 1
            informationSubview.layer.borderColor = UIColor.systemBlue.cgColor
            informationSubview.layer.cornerRadius = 8
        }
    }
    
    func setupViews() {
        // View parent
        outerView.backgroundColor = UIColor.white
        outerView.translatesAutoresizingMaskIntoConstraints = false

        // ================== View first ==================
        // View timeline
        firstSubview.backgroundColor = UIColor.blue
        firstSubview.translatesAutoresizingMaskIntoConstraints = false

        // View circle
        circleView.layer.cornerRadius = 5
        circleView.translatesAutoresizingMaskIntoConstraints = false
        firstSubview.addSubview(circleView)
        
        // ================== View second ==================
        // View title information
        secondSubview.backgroundColor = UIColor.white
        secondSubview.translatesAutoresizingMaskIntoConstraints = false

        // Label time
        topLabel.textColor = UIColor.systemGreen
        topLabel.font = UIFont.systemFont(ofSize: 14)
        topLabel.translatesAutoresizingMaskIntoConstraints = false
        secondSubview.addSubview(topLabel)

        // Label address
        bottomLabel.textColor = UIColor.black
        bottomLabel.font = UIFont.systemFont(ofSize: 12)
        bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomLabel.numberOfLines = 2
        secondSubview.addSubview(bottomLabel)

        // ================== View Pick-Drop ==================
        // View total User pick-drop
        thirdSubview.backgroundColor = UIColor.white
        thirdSubview.translatesAutoresizingMaskIntoConstraints = false

        let iconPick = UIImage(named: "ic_pick_svg")
        viewIconPick.image = iconPick
        viewIconPick.translatesAutoresizingMaskIntoConstraints = false
        thirdSubview.addSubview(viewIconPick)

        totalPick.textColor = UIColor.black
        totalPick.font = UIFont.systemFont(ofSize: 12)
        totalPick.translatesAutoresizingMaskIntoConstraints = false
        thirdSubview.addSubview(totalPick)
        
        let iconDrop = UIImage(named: "ic_drop_svg")
        viewIconDrop.image = iconDrop
        viewIconDrop.translatesAutoresizingMaskIntoConstraints = false
        thirdSubview.addSubview(viewIconDrop)

        
        totalDrop.textColor = UIColor.black
        totalDrop.font = UIFont.systemFont(ofSize: 12)
        totalDrop.translatesAutoresizingMaskIntoConstraints = false
        thirdSubview.addSubview(totalDrop)

        confirmUserPickDrop.font = UIFont.systemFont(ofSize: 12)
        confirmUserPickDrop.translatesAutoresizingMaskIntoConstraints = false
        thirdSubview.addSubview(confirmUserPickDrop)

        // ================== Information view ==================
        informationSubview.backgroundColor = UIColor.white
        informationSubview.translatesAutoresizingMaskIntoConstraints = false
        informationSubview.addSubview(secondSubview)
        informationSubview.addSubview(thirdSubview)

        // Add subviews to outerView
        outerView.addSubview(firstSubview)
        outerView.addSubview(informationSubview)

        // Add outerView to cell's contentView
        self.contentView.addSubview(outerView)

        // Add constraints
        NSLayoutConstraint.activate([
            // Outer view constraints
            outerView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            outerView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            outerView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            outerView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),

            // First subview constraints
            firstSubview.leadingAnchor.constraint(equalTo: outerView.leadingAnchor),
            firstSubview.topAnchor.constraint(equalTo: outerView.topAnchor),
            firstSubview.bottomAnchor.constraint(equalTo: outerView.bottomAnchor),
            firstSubview.widthAnchor.constraint(equalToConstant: 12),

            // Circle view constraints
            circleView.centerXAnchor.constraint(equalTo: firstSubview.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: firstSubview.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 10),
            circleView.heightAnchor.constraint(equalToConstant: 10),
            
            // Information subview contraints
            informationSubview.leadingAnchor.constraint(equalTo: firstSubview.trailingAnchor, constant: 8),
            informationSubview.topAnchor.constraint(equalTo: outerView.topAnchor, constant: 4),
            informationSubview.bottomAnchor.constraint(equalTo: outerView.bottomAnchor, constant: -4),
            informationSubview.trailingAnchor.constraint(equalTo: outerView.trailingAnchor, constant: -4),

            // Second subview constraints
            secondSubview.leadingAnchor.constraint(equalTo: informationSubview.leadingAnchor),
            secondSubview.topAnchor.constraint(equalTo: informationSubview.topAnchor),
            secondSubview.bottomAnchor.constraint(equalTo: informationSubview.bottomAnchor),

            // Top label constraints
            topLabel.leadingAnchor.constraint(equalTo: secondSubview.leadingAnchor, constant: 5),
            topLabel.topAnchor.constraint(equalTo: secondSubview.topAnchor, constant: 10),
            topLabel.trailingAnchor.constraint(equalTo: secondSubview.trailingAnchor),

            // Bottom label constraints
            bottomLabel.leadingAnchor.constraint(equalTo: secondSubview.leadingAnchor, constant: 5),
            bottomLabel.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 5),
            bottomLabel.trailingAnchor.constraint(equalTo: secondSubview.trailingAnchor, constant: -5),

            // Third subview constraints
            thirdSubview.trailingAnchor.constraint(equalTo: informationSubview.trailingAnchor),
            thirdSubview.topAnchor.constraint(equalTo: informationSubview.topAnchor),
            thirdSubview.bottomAnchor.constraint(equalTo: informationSubview.bottomAnchor),
            thirdSubview.leadingAnchor.constraint(greaterThanOrEqualTo: secondSubview.trailingAnchor, constant: 5),
            
            // Icon pick constraints
            viewIconPick.topAnchor.constraint(equalTo: thirdSubview.topAnchor, constant: 10),
            viewIconPick.widthAnchor.constraint(equalToConstant: sizeIcon),
            viewIconPick.heightAnchor.constraint(equalToConstant: sizeIcon),

            // Total pick label constraints
            totalPick.leadingAnchor.constraint(equalTo: viewIconPick.trailingAnchor, constant: 5),
            totalPick.centerYAnchor.constraint(equalTo: viewIconPick.centerYAnchor),
            totalPick.trailingAnchor.constraint(equalTo: thirdSubview.trailingAnchor, constant: -5),

            
            // Icon drop constraints
            viewIconDrop.topAnchor.constraint(equalTo: totalPick.bottomAnchor, constant: 5),
            viewIconDrop.widthAnchor.constraint(equalToConstant: sizeIcon),
            viewIconDrop.heightAnchor.constraint(equalToConstant: sizeIcon),

            // Total drop label constraints
            totalDrop.leadingAnchor.constraint(equalTo: viewIconDrop.trailingAnchor, constant: 5),
            totalDrop.centerYAnchor.constraint(equalTo: viewIconDrop.centerYAnchor),
            totalDrop.trailingAnchor.constraint(equalTo: thirdSubview.trailingAnchor, constant: -5),
            
            // Confirm User pick-drop label constraints
            confirmUserPickDrop.topAnchor.constraint(equalTo: viewIconDrop.bottomAnchor, constant: 5),
            confirmUserPickDrop.trailingAnchor.constraint(equalTo: thirdSubview.trailingAnchor, constant: -5),
        ])
    }
}
