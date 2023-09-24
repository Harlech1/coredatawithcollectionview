//
//  ViewController.swift
//  TimeForCoreData
//
//  Created by Turker Kizilcik on 21.09.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {

    var titleArray = [String]()
    var contentArray = [String]()
    var idArray = [UUID]()
    
    var selectedCell = ""
    var selectedCellID : UUID?
    
    var number = 1
    var collectionView : UICollectionView!

    override func viewDidLoad() {
        let layout = UICollectionViewFlowLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        view.addSubview(collectionView!)
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        
        if number == 1 {
            collectionView?.register(CustomCellWithoutContent.self, forCellWithReuseIdentifier: "cell")
        } else {
            collectionView?.register(CustomCell.self, forCellWithReuseIdentifier: "cell")
        }
    
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(nextButtonTapped))
        navigationItem.rightBarButtonItem = addButton
        
        getData()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }

    @objc func nextButtonTapped() {
            selectedCell = ""
            performSegue(withIdentifier: "toNoteCreator", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if number == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCellWithoutContent
            cell.titleLabel.text = titleArray[indexPath.row]
            //cell.contentLabel.text = contentArray[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
            cell.titleLabel.text = titleArray[indexPath.row]
            cell.contentLabel.text = contentArray[indexPath.row]
            return cell
        }
            
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNoteCreator" {
            let destinationVC = segue.destination as! NotesViewController
            destinationVC.chosenCell = selectedCell
            destinationVC.chosenCellID = selectedCellID
        }
            
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width / 2) - 5
        let height: CGFloat = 150
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            selectedCell = titleArray[indexPath.row]
            selectedCellID = idArray[indexPath.row]
            let selectedIndexPath = indexPath
            print("Tapped cell at section \(selectedIndexPath.section), item \(selectedIndexPath.item)")
            performSegue(withIdentifier: "toNoteCreator", sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    @objc func getData() {
        titleArray.removeAll(keepingCapacity: false)
        contentArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity:  false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "title") as? String {
                        self.titleArray.append(title)
                    }
                    
                    if let content = result.value(forKey: "content") as? String {
                        self.contentArray.append(content)
                    }
                    
                    if let id = result.value(forKey: "id") as? UUID {
                        self.idArray.append(id)
                    }
                    
                    self.collectionView.reloadData()
                }
            }
            
        } catch {
            print("error")
        }
        
    }

}

class CustomCell : UICollectionViewCell {
    
    let titleLabel = UILabel()
    let contentLabel = UILabel()
    let labelsContainerView = UIView()
    let scrollView = UIScrollView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        // Add the scrollView to the main view
        addSubview(scrollView)

        // Set constraints for the scrollView to cover the whole view
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Add labelsContainerView to the scrollView
        scrollView.addSubview(labelsContainerView)

        // Set constraints for labelsContainerView inside the scrollView
        NSLayoutConstraint.activate([
            labelsContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            labelsContainerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            labelsContainerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            labelsContainerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            labelsContainerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        
            labelsContainerView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(labelsContainerView)
            
            // Add title label to the container view
            labelsContainerView.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            // Add content label to the container view
            labelsContainerView.addSubview(contentLabel)
            contentLabel.translatesAutoresizingMaskIntoConstraints = false
            contentLabel.numberOfLines = 0  // Allow multiple lines
            
            // Set constraints for labelsContainerView
            labelsContainerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            labelsContainerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            labelsContainerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            labelsContainerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            
            // Set corner radius for the container view (to make it round)
            labelsContainerView.layer.cornerRadius = 10
            labelsContainerView.layer.backgroundColor = CGColor(red: 42/255, green: 32/255, blue: 205/255, alpha: 1.0)
            //236, 186, 19
            //(132, 164, 194)
            //42 32 205
            labelsContainerView.layer.masksToBounds = true
            
            // Set title label constraints
            titleLabel.topAnchor.constraint(equalTo: labelsContainerView.topAnchor, constant: 10).isActive = true
            titleLabel.leadingAnchor.constraint(equalTo: labelsContainerView.leadingAnchor, constant: 10).isActive = true
            titleLabel.trailingAnchor.constraint(equalTo: labelsContainerView.trailingAnchor, constant: -10).isActive = true
            titleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true  // Set title label height


            // Set content label constraints
            let contentTopConstraint = contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0)
            contentTopConstraint.priority = UILayoutPriority(999)  // Set a lower priority for this constraint

            let contentBottomConstraint = contentLabel.bottomAnchor.constraint(lessThanOrEqualTo: labelsContainerView.bottomAnchor, constant: -10)
            contentBottomConstraint.priority = UILayoutPriority(999)  // Set a lower priority for this constraint

            contentTopConstraint.isActive = true
            contentBottomConstraint.isActive = true

            contentLabel.leadingAnchor.constraint(equalTo: labelsContainerView.leadingAnchor, constant: 10).isActive = true  // Adjust the constant value as needed
            contentLabel.trailingAnchor.constraint(equalTo: labelsContainerView.trailingAnchor, constant: -10).isActive = true
            // Additional configurations (if needed)
            titleLabel.textColor = UIColor.white
            titleLabel.textAlignment = .center
            contentLabel.textColor = UIColor.gray
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CustomCellTrying: UICollectionViewCell {

    let titleLabel = UILabel()
    let contentLabel = UILabel()
    let labelsContainerView = UIView()
    let scrollView = UIScrollView()
    let deleteButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        scrollView.addSubview(labelsContainerView)

        NSLayoutConstraint.activate([
            labelsContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            labelsContainerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            labelsContainerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            labelsContainerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            labelsContainerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        labelsContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(labelsContainerView)

        labelsContainerView.layer.cornerRadius = 10
        labelsContainerView.layer.backgroundColor = UIColor(red: 42/255, green: 32/255, blue: 205/255, alpha: 1.0).cgColor
        labelsContainerView.layer.masksToBounds = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        labelsContainerView.addSubview(titleLabel)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center

        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        labelsContainerView.addSubview(contentLabel)
        contentLabel.textColor = UIColor.gray
        contentLabel.numberOfLines = 0

        titleLabel.topAnchor.constraint(equalTo: labelsContainerView.topAnchor, constant: 10).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: labelsContainerView.leadingAnchor, constant: 10).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: labelsContainerView.trailingAnchor, constant: -10).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

        let contentTopConstraint = contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0)
        contentTopConstraint.priority = UILayoutPriority(999)

        let contentBottomConstraint = contentLabel.bottomAnchor.constraint(lessThanOrEqualTo: labelsContainerView.bottomAnchor, constant: -10)
        contentBottomConstraint.priority = UILayoutPriority(999)

        contentTopConstraint.isActive = true
        contentBottomConstraint.isActive = true

        contentLabel.leadingAnchor.constraint(equalTo: labelsContainerView.leadingAnchor, constant: 10).isActive = true
        contentLabel.trailingAnchor.constraint(equalTo: labelsContainerView.trailingAnchor, constant: -10).isActive = true

        deleteButton.setTitle("X", for: .normal)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        labelsContainerView.addSubview(deleteButton)

        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: labelsContainerView.topAnchor, constant: 10),
            deleteButton.leadingAnchor.constraint(equalTo: labelsContainerView.leadingAnchor, constant: 10),
            deleteButton.widthAnchor.constraint(equalToConstant: 20),
            deleteButton.heightAnchor.constraint(equalToConstant: 20)
        ])

        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }

    @objc private func deleteButtonTapped() {
        // Silme butonuna tıklandığında yapılacak işlemler buraya eklenecek
        // Örneğin: Silme işlemleri ve güncellemeler
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class CustomCellWithoutContent : UICollectionViewCell {
    let titleLabel = UILabel()
    //let contentLabel = UILabel()
    let labelsContainerView = UIView()
    let scrollView = UIScrollView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        // Add the scrollView to the main view
        addSubview(scrollView)

        // Set constraints for the scrollView to cover the whole view
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Add labelsContainerView to the scrollView
        scrollView.addSubview(labelsContainerView)

        // Set constraints for labelsContainerView inside the scrollView
        NSLayoutConstraint.activate([
            labelsContainerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            labelsContainerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            labelsContainerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            labelsContainerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            labelsContainerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        
            labelsContainerView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(labelsContainerView)
            
            // Add title label to the container view
            labelsContainerView.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            // Add content label to the container view
            //labelsContainerView.addSubview(contentLabel)
            //contentLabel.translatesAutoresizingMaskIntoConstraints = false
            //contentLabel.numberOfLines = 0  // Allow multiple lines
            
            // Set constraints for labelsContainerView
            labelsContainerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            labelsContainerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            labelsContainerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            labelsContainerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            
            // Set corner radius for the container view (to make it round)
            labelsContainerView.layer.cornerRadius = 10
            labelsContainerView.layer.backgroundColor = CGColor(red: 42/255, green: 32/255, blue: 205/255, alpha: 1.0)
            //236, 186, 19
            //(132, 164, 194)
            //42 32 205
            labelsContainerView.layer.masksToBounds = true
            
            // Set title label constraints
            titleLabel.topAnchor.constraint(equalTo: labelsContainerView.topAnchor, constant: 10).isActive = true
            titleLabel.leadingAnchor.constraint(equalTo: labelsContainerView.leadingAnchor, constant: 10).isActive = true
            titleLabel.trailingAnchor.constraint(equalTo: labelsContainerView.trailingAnchor, constant: -10).isActive = true
            titleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true  // Set title label height


            // Set content label constraints
            //let contentTopConstraint = contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0)
            //contentTopConstraint.priority = UILayoutPriority(999)  // Set a lower priority for this constraint

            //let contentBottomConstraint = contentLabel.bottomAnchor.constraint(lessThanOrEqualTo: labelsContainerView.bottomAnchor, constant: -10)
            //contentBottomConstraint.priority = UILayoutPriority(999)  // Set a lower priority for this constraint

            //contentTopConstraint.isActive = true
            //contentBottomConstraint.isActive = true

            //contentLabel.leadingAnchor.constraint(equalTo: labelsContainerView.leadingAnchor, constant: 10).isActive = true  // Adjust the constant value as needed
            //contentLabel.trailingAnchor.constraint(equalTo: labelsContainerView.trailingAnchor, constant: -10).isActive = true
            // Additional configurations (if needed)
            titleLabel.textColor = UIColor.white
            titleLabel.textAlignment = .center
            //contentLabel.textColor = UIColor.gray
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
