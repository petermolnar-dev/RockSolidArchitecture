//
//  ViewController.swift
//  RockSolidArchitecture
//
//  Created by Peter Molnar on 12/07/2025.
//

import UIKit

class ViewController: UIViewController {
    struct Song {
        let artistId: String
        let collectionId: String
        let trackId: String
        let artistName: String
        let collectionName: String
        let trackName: String
        let collectionCensoredName: String?
        let trackCensoredName: String?
        let isStreamable: Bool
    }
    
    var songs: [Song] = []
    
    override func viewDidLoad() {
        
        fetchData()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SongTableViewCell.self, forCellReuseIdentifier: "SongTableViewCell")
    }
    
    private func fetchData() {
        let url = URL(string: "https://itunes.apple.com/search?term=breakpoints&media=music&entity=song")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                guard let jsonsongs = json?["results"] as? [[String: Any]] else {
                    print("No JSON received")
                    return
                }
                
                DispatchQueue.main.async {
                    self.songs = jsonsongs.map { dictionary in
                        let artistName = dictionary["artistName"] as? String ?? ""
                        let trackName = dictionary["trackName"] as? String ?? ""
                        
                        if artistName.contains("Dempsey") {
                            return Song(artistId: dictionary["artistId"] as? String ?? "",
                                        collectionId: dictionary["collectionId"] as? String ?? "",
                                        trackId: dictionary["trackId"] as? String ?? "",
                                        artistName: artistName,
                                        collectionName: dictionary["collectionName"] as? String ?? "",
                                        trackName: trackName,
                                        collectionCensoredName: dictionary["collectionCensoredName"] as? String,
                                        trackCensoredName: dictionary["trackCensoredName"] as? String,
                                        isStreamable: (dictionary["isStreamable"] as? Bool) ?? false)
                        } else {
                            return Song(artistId: "", collectionId: "", trackId: "", artistName: "", collectionName: "", trackName: "", collectionCensoredName: nil, trackCensoredName: nil, isStreamable: false)
                        }
                    }
                    self.tableView.reloadData()
                    
                    if let songData = try? JSONEncoder().encode(self.songs) {
                        UserDefaults.standard.set(songData, forKey: "foundSongs")
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        
        task.resume()
    }
    
    @IBOutlet weak var tableView: UITableView!
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongTableViewCell", for: indexPath) as! SongTableViewCell
        
        let song = songs[indexPath.row]
        cell.titleLabel.text = song.trackName
        cell.subtitleLabel.text = song.artistName
        
        return cell
    }
}

class SongTableViewCell: UITableViewCell {
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width - 32),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.widthAnchor.constraint(equalToConstant: contentView.frame.width - 32),
            subtitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 16)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ViewController.Song: Encodable {}
