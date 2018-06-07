/**
 * Copyright IBM Corporation 2017, 2018
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import UIKit

class ResultsTableViewController: UITableViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    var classificationLabel = ""
    var discoveryResult = ""
    var discoveryResultTitle = ""
    var discoveryResultSubtitle = ""


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 85.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.isScrollEnabled = false
        print(discoveryResult)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if classificationLabel.count > 0 {
            return 2
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.item == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellClassification", for: indexPath) as! ResultTableClassificationViewCell
            cell.label.text = classificationLabel
            cell.swipeLabel.text = "Swipe up for more information ↑"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellDiscovery", for: indexPath) as! ResultTableDiscoveryViewCell
            cell.title.text = discoveryResultTitle
            cell.classificationLabel.text = discoveryResultSubtitle.count > 0 ? "- " + discoveryResultSubtitle : ""
            cell.cellDescription.numberOfLines = 0
            cell.cellDescription.lineBreakMode = .byWordWrapping
            cell.cellDescription.text = discoveryResult
            return cell
        }
    }

}

extension ResultsTableViewController: PulleyDrawerViewControllerDelegate {
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 85.0
    }

    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 264.0
    }


    func supportedDrawerPositions() -> [PulleyPosition] {
        // You can specify the drawer positions you support. This is the same as: [.open, .partiallyRevealed, .collapsed, .closed]
        return PulleyPosition.all
    }

    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        tableView.isScrollEnabled = drawer.drawerPosition == .open
    }
}



