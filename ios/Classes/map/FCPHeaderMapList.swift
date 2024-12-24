//
//  FCPHeaderMapList.swift
//  Pods
//
//  Created by dev on 18/12/24.
//


import Foundation
import UIKit

class FCPHeaderMapList: UIViewController {
    let headerView = UIView()
    let labelNameTrip = UILabel()
    let firstView = UIView()
    let firstTimeLabel = UILabel()
    let firstLocationLabel = UILabel()
    let centerView = UIView()
    let centerRemainTimeLabel = UILabel()
    let centerImage = UIImageView()
    let centerRemainDistanceLabel = UILabel()
    let lastView = UIView()
    let lastTimeLabel = UILabel()
    let lastLocationLabel = UILabel()
    let lastEstimateLabel = UILabel()
    
    var estimatePoint: FCPMapListHeaderModel?
    var nextPoint: FCPMapListModel?
    
    // Khởi tạo tùy chỉnh nhận dữ liệu
    init(estimatePoint: FCPMapListHeaderModel?, nextPoint: FCPMapListModel?) {
        self.estimatePoint = estimatePoint
        self.nextPoint = nextPoint
        super.init(nibName: nil, bundle: nil)
    }
    
    // Khởi tạo bắt buộc từ `UIViewController`
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.nextPoint == nil {
            setupWithoutNextPoint()
        } else {
            setupViews()
            setupConstraints()
        }
    }
    
    func setupViews() {
        headerView.frame = CGRect(x: 0, y: 0, width: 300, height: 70)
        headerView.backgroundColor = UIColor.white
        view.addSubview(headerView)
        
        // ================== View first ==================
        firstView.translatesAutoresizingMaskIntoConstraints = false
        
        firstTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        firstTimeLabel.textColor = UIColor.black
        firstTimeLabel.font = UIFont.systemFont(ofSize: 12)
        firstTimeLabel.text = estimatePoint?.getTitleTime() ?? ""
        
        firstLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        firstLocationLabel.textColor = UIColor.black
        firstLocationLabel.font = UIFont.systemFont(ofSize: 10)
        firstLocationLabel.numberOfLines = 2
        firstLocationLabel.text = estimatePoint?.getTitle() ?? ""
        
        firstView.addSubview(firstTimeLabel)
        firstView.addSubview(firstLocationLabel)
        
        // ================== View center ==================
        centerView.translatesAutoresizingMaskIntoConstraints = false
        
        centerRemainTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        centerRemainTimeLabel.textColor = UIColor.black
        centerRemainTimeLabel.font = UIFont.systemFont(ofSize: 9)
        centerRemainTimeLabel.text = estimatePoint?.getTime() ?? ""
        
        centerImage.translatesAutoresizingMaskIntoConstraints = false
        if let arrowRight = UIImage(named: "arrow_right") {
            centerImage.image = arrowRight
        } else {
            // Handle missing image
            centerImage.backgroundColor = UIColor.red
        }
        
        centerRemainDistanceLabel.translatesAutoresizingMaskIntoConstraints = false
        centerRemainDistanceLabel.textColor = UIColor.black
        centerRemainDistanceLabel.font = UIFont.systemFont(ofSize: 9)
        centerRemainDistanceLabel.text = estimatePoint?.getDistance() ?? ""
        
        centerView.addSubview(centerRemainTimeLabel)
        centerView.addSubview(centerImage)
        centerView.addSubview(centerRemainDistanceLabel)
        
        // ================== View last ==================
        lastView.translatesAutoresizingMaskIntoConstraints = false
        
        lastTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        lastTimeLabel.textColor = UIColor.black
        lastTimeLabel.font = UIFont.systemFont(ofSize: 12)
        lastTimeLabel.text = nextPoint?.getTime() ?? ""
        
        lastLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        lastLocationLabel.textColor = UIColor.black
        lastLocationLabel.font = UIFont.systemFont(ofSize: 10)
        lastLocationLabel.text = nextPoint?.getAddress() ?? ""
        lastLocationLabel.numberOfLines = 2
        
        lastEstimateLabel.translatesAutoresizingMaskIntoConstraints = false
        lastEstimateLabel.textColor = (nextPoint?.getLateEstimateTime() ?? false) ? UIColor.red : UIColor.systemGreen
        lastEstimateLabel.font = UIFont.systemFont(ofSize: 10)
        lastEstimateLabel.text = nextPoint?.getEstimateTime() ?? ""
        
        lastView.addSubview(lastTimeLabel)
        lastView.addSubview(lastLocationLabel)
        lastView.addSubview(lastEstimateLabel)
        
        // Add subviews to headerView
        headerView.addSubview(firstView)
        headerView.addSubview(centerView)
        headerView.addSubview(lastView)
    }
    
    func setupConstraints() {
        // Add constraints
        NSLayoutConstraint.activate([
            // First view constraints
            firstView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            firstView.topAnchor.constraint(equalTo: headerView.topAnchor),
            firstView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            firstView.trailingAnchor.constraint(equalTo: centerView.leadingAnchor, constant: -5),
            
            // firstTimeLabel constraints
            firstTimeLabel.leadingAnchor.constraint(equalTo: firstView.leadingAnchor, constant: 50),
            firstTimeLabel.topAnchor.constraint(equalTo: firstView.topAnchor, constant: 10),
            
            // firstLocationLabel constraints
            firstLocationLabel.leadingAnchor.constraint(equalTo: firstView.leadingAnchor, constant: 50),
            firstLocationLabel.topAnchor.constraint(equalTo: firstTimeLabel.bottomAnchor, constant: 5),
            firstLocationLabel.trailingAnchor.constraint(equalTo: firstView.trailingAnchor, constant: -10),
            
            // Center view constraints
            centerView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor, constant: 5),
            centerView.topAnchor.constraint(equalTo: headerView.topAnchor),
            centerView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            centerView.widthAnchor.constraint(equalToConstant: 50),
            
            // centerRemainTimeLabel constraints
            centerRemainTimeLabel.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
            centerRemainTimeLabel.topAnchor.constraint(equalTo: centerView.topAnchor, constant: 10),
            
            // centerImage constraints
            centerImage.topAnchor.constraint(equalTo: centerRemainTimeLabel.bottomAnchor, constant: 5),
            centerImage.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
            centerImage.leadingAnchor.constraint(equalTo: centerView.leadingAnchor),
            centerImage.trailingAnchor.constraint(equalTo: centerView.trailingAnchor),
            
            // centerRemainDistanceLabel constraints
            centerRemainDistanceLabel.centerXAnchor.constraint(equalTo: centerView.centerXAnchor),
            centerRemainDistanceLabel.topAnchor.constraint(equalTo: centerImage.bottomAnchor, constant: 5),
            
            // Last view constraints
            lastView.leadingAnchor.constraint(equalTo: centerView.trailingAnchor, constant: 5),
            lastView.topAnchor.constraint(equalTo: headerView.topAnchor),
            lastView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            lastView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            
            // lastTimeLabel constraints
            lastTimeLabel.trailingAnchor.constraint(equalTo: lastView.trailingAnchor, constant: -10),
            lastTimeLabel.topAnchor.constraint(equalTo: lastView.topAnchor, constant: 10),
            
            // lastLocationLabel constraints
            lastLocationLabel.trailingAnchor.constraint(equalTo: lastView.trailingAnchor, constant: -10),
            lastLocationLabel.leadingAnchor.constraint(greaterThanOrEqualTo: lastView.leadingAnchor),
            lastLocationLabel.topAnchor.constraint(equalTo: lastTimeLabel.bottomAnchor, constant: 5),
            
            // lastEstimateLabel constraints
            lastEstimateLabel.trailingAnchor.constraint(equalTo: lastView.trailingAnchor, constant: -10),
            lastEstimateLabel.topAnchor.constraint(equalTo: lastLocationLabel.bottomAnchor, constant: 5),
        ])
    }
    
    func setupWithoutNextPoint() {
        headerView.frame = CGRect(x: 0, y: 0, width: 300, height: 70)
        headerView.backgroundColor = UIColor.white
        view.addSubview(headerView)
        labelNameTrip.backgroundColor = .clear
        labelNameTrip.text = estimatePoint?.getNameTrip() ?? ""
        labelNameTrip.font = UIFont.systemFont(ofSize: 20)
        labelNameTrip.textAlignment = .left
        labelNameTrip.textColor = .black
        labelNameTrip.numberOfLines = 2
        labelNameTrip.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(labelNameTrip)
        NSLayoutConstraint.activate([
            // First view constraints
            labelNameTrip.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 50),
            labelNameTrip.topAnchor.constraint(equalTo: headerView.topAnchor),
            labelNameTrip.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            labelNameTrip.trailingAnchor.constraint(equalTo: headerView.trailingAnchor)
        ])
    }
    
    func updateValue(data: FCPMapListHeaderModel, nextPoint: FCPMapListModel) {
        firstTimeLabel.text = data.getTitleTime() ?? ""
        firstLocationLabel.text = data.getTitle() ?? ""
        centerRemainTimeLabel.text = data.getTime() ?? ""
        centerRemainDistanceLabel.text = data.getDistance() ?? ""
        lastTimeLabel.text = nextPoint.getTime() ?? ""
        lastLocationLabel.text = nextPoint.getAddress() ?? ""
        lastEstimateLabel.textColor = nextPoint.getLateEstimateTime() ? UIColor.red : UIColor.systemGreen
        lastEstimateLabel.text = nextPoint.getEstimateTime() ?? ""
    }
}
