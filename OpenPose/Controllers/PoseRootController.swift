//
//  PoseRootController.swift
//  OpenPose
//
//  Created by ben on 2019/7/18.
//  Copyright © 2019 ben. All rights reserved.
//

import UIKit

class ExampleDescription {
    var name: String?
    var description: String?
    
    init(name:String, description: String) {
        self.name = name
        self.description = description
    }
}

class PoseRootController: UITableViewController {
    
    @IBOutlet var tvExamples: UITableView!
    var descriptions = [ExampleDescription]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. opencv image2gray
        let openCVImage = ExampleDescription(name: "OpenCV image",
                                            description: "Convert image to gray")
        descriptions.append(openCVImage)

        // 2. opencv image2gray
        let openCVVideoStream = ExampleDescription(name: "OpenCV video stream",
                                            description: "Convert video stream to gray")
        descriptions.append(openCVVideoStream)

        // 3. openpose heatmap
        let heatMap = ExampleDescription(name: "Heat map",
                                         description: "show the probability of the keypoints")
        descriptions.append(heatMap)
        
        // 4. openpose heatmap with video
        let heatMapVideo = ExampleDescription(name: "Heat map video",
                                         description: "show the probability of the keypoints on video")
        descriptions.append(heatMapVideo)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return descriptions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "example list")
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "example list")
        }
        
        cell?.textLabel?.text = descriptions[indexPath.row].name
        cell?.detailTextLabel?.text = descriptions[indexPath.row].description
        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch descriptions[indexPath.row].name {
        case "OpenCV image":
            performSegue(withIdentifier: "opencvImage", sender: self)
        case "OpenCV video stream":
            performSegue(withIdentifier: "opencvVideoStream", sender: self)
        case "Heat map":
            performSegue(withIdentifier: "heatMap", sender: self)
        case "Heat map video":
            performSegue(withIdentifier: "heatMapVideo", sender: self)
        default:
            break
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
