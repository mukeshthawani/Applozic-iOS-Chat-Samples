//
//  ConversationViewController+TableView.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard var message = viewModel.messageForRow(indexPath: indexPath) else {
            return UITableViewCell()
        }
        print("Cell updated at row: ", indexPath.row, "and type is: ", message.messageType)
        switch message.messageType {
        case .text:
            if message.isMyMessage {

                let cell: MyMessageCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.update(viewModel: message)
                cell.update(chatBar: self.chatBar)
                return cell

            } else {
                let cell: FriendMessageCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.update(viewModel: message)
                cell.update(chatBar: self.chatBar)
                return cell
            }
        case .photo:
            if message.isMyMessage {
                // Right now ratio is fixed to 1.77
                if message.ratio < 1 {
                    print("image messsage called")
                    let cell: MyPhotoPortalCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                    cell.update(viewModel: message)
                    return cell

                } else {
                    let cell: MyPhotoLandscapeCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                    cell.update(viewModel: message)
                    return cell
                }

            } else {
                if message.ratio < 1 {

                    let cell: FriendPhotoPortalCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                    cell.update(viewModel: message)
                    return cell

                } else {
                    let cell: FriendPhotoLandscapeCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                    cell.update(viewModel: message)
                    return cell
                }
            }
        case .voice:
            print("voice cell loaded with url", message.filePath)
            print("current voice state: ", message.voiceCurrentState, "row", indexPath.row, message.voiceTotalDuration, message.voiceData)
            print("voice identifier: ", message.identifier, "and row: ", indexPath.row)
            if message.voiceData ==  nil {
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                if let path = message.filePath, let data = NSData(contentsOfFile: (documentsURL.appendingPathComponent(path)).path) as Data? {
                    self.viewModel.updateMessageModelAt(indexPath: indexPath, data: data)
                } else {
                    viewModel.getAudioData(for: indexPath) { data in
                        guard let voiceData = data else { return }
                        self.viewModel.updateMessageModelAt(indexPath: indexPath, data: voiceData)
                    }
                }
            }

            if message.voiceTotalDuration == 0 {
                if let data = message.voiceData {
                    let voice = data as NSData
                    do {
                        let player = try AVAudioPlayer(data: voice as Data, fileTypeHint: AVFileTypeWAVE)
                        message.voiceTotalDuration = CGFloat(player.duration)
                    } catch let error as NSError {
                        //                        Logger.error(message: error)
                    }
                }
            }

            if message.isMyMessage {
                let cell: MyVoiceCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                //                cell.backgroundColor = UIColor.white
                cell.update(viewModel: message)
                cell.setCellDelegate(delegate: self)
                return cell
            } else {
                let cell: FriendVoiceCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                //                cell.backgroundColor = UIColor.white
                cell.update(viewModel: message)
                cell.setCellDelegate(delegate: self)
                return cell
            }
        case .location:
            if message.isMyMessage {
                let cell: MyLocationCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.update(viewModel: message)
                cell.setDelegate(locDelegate: self)
                return cell

            } else {
                let cell: FriendLocationCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.update(viewModel: message)
                cell.setDelegate(locDelegate: self)
                return cell
            }
        case .information:
            let cell: InformationCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.update(viewModel: message)
            return cell
        default:
            NSLog("Wrong choice")
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.heightForRow(indexPath: indexPath, cellFrame: self.view.frame)
    }


    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let heightForHeaderInSection: CGFloat = 40.0

        guard let message1 = viewModel.messageForRow(indexPath: IndexPath(row: 0, section: section)) else {
            return 0.0
        }
        let date1 = message1.date
        //        if section == 0 {
        //            return (message1.type == .createGroup ? 0.0 : heightForHeaderInSection)
        //        }

        if section == 0 {
            return heightForHeaderInSection
        }

        guard let message2 = viewModel.messageForRow(indexPath: IndexPath(row: 0, section: section - 1)) else {
            return 0.0
        }
        let date2 = message2.date

        switch Calendar.current.compare(date1, to: date2, toGranularity: .day) {
        case .orderedDescending:
            return heightForHeaderInSection

        default:
            //            return (message2.type == .createGroup ? heightForHeaderInSection : 0.0)
            return 0.0
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let message = viewModel.messageForRow(indexPath: IndexPath(row: 0, section: section)) else {
            return nil
        }
        let date = message.date

        let dateView = DateSectionHeaderView.instanceFromNib()
        dateView.setupDate(withDateFormat: date.stringCompareCurrentDate())

        return dateView
    }

    //MARK: Paging

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (decelerate) {return}
        configurePaginationWindow()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        configurePaginationWindow()
    }

    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        configurePaginationWindow()
    }

    func configurePaginationWindow() {
        if (self.tableView.frame.equalTo(CGRect.zero)) {return}
        if (self.tableView.isDragging) {return}
        if (self.tableView.isDecelerating) {return}
        let topOffset = -self.tableView.contentInset.top
        let distanceFromTop = self.tableView.contentOffset.y - topOffset
        let minimumDistanceFromTopToTriggerLoadingMore: CGFloat = 200
        let nearTop = distanceFromTop <= minimumDistanceFromTopToTriggerLoadingMore
        if (!nearTop) {return}
        
        self.viewModel.nextPage()
    }
}
