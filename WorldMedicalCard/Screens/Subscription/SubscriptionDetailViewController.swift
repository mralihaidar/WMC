//
//  SubscriptionDetailViewController.swift
//  WorldMedicalCard
//
//  Created by Apphuset on 03/06/2022.
//

import UIKit

final class SubscriptionDetailViewController: UIViewController {

    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var managerLabel: UILabel!
    @IBOutlet var occupancyLabel: UILabel!
    @IBOutlet var expirationLabel: UILabel!

    @IBOutlet var memberDescriptionLabel: UILabel!
    @IBOutlet var addMemberView: UIView!

    @IBOutlet var loadingView: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!

    @IBOutlet var cancelSubscriptionButton: UIButton!
    @IBOutlet var cancelLoadingView: UIActivityIndicatorView!

    var subscriptionListItem: SubscriptionListItem! // injection
    private var subscription: Subscription?
    private var removingMemberIds = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L("subscription_detail_title")
        tableView.delegate = self
        tableView.dataSource = self

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }

        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = refresher

        reloadBaseInfo()
        tableView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSubscription()
    }

    // MARK: - Actions

    @IBAction func addMemberTapped() {
        let invite = SubscriptionInviteViewController.instantiateFrom(storyboard: .subscription)
        invite.subscriptionId = subscriptionListItem.id

        invite.invitedHandler = { [weak self] in
            self?.loadSubscription()
        }

        let nvc = UINavigationController(rootViewController: invite)
        nvc.isModalInPresentation = true
        present(nvc, animated: true)
    }

    @objc func pullToRefresh() {
        loadSubscription()
    }

    @IBAction func cancelSubscriptionTapped() {
        let alert = UIAlertController(
            title: L("subscription_detail_alert_cancel_subcription_title"),
            message: L("subscription_detail_alert_cancel_subcription_message"),
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L("subscription_detail_alert_cancel_subcription_cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: L("subscription_detail_alert_cancel_subcription_confirm"), style: .destructive, handler: { _ in
            self.cancelSubscription()
        }))

        present(alert, animated: true)
    }
}

extension SubscriptionDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        subscription?.members?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 2))
        view.backgroundColor = .clear
        return view
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell", for: indexPath) as! SubscriptionMemberTableViewCell
        if let member = subscription?.members?[indexPath.section] {
            cell.fill(member: member, isLoading: removingMemberIds.contains(member.id))
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let id = subscription?.members?[indexPath.row].id else {
            return false
        }

        return !removingMemberIds.contains(id)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: nil) { _, _, completion in
            self.showAlertRemovingAtIndexPath(indexPath)
            completion(true)
        }
        action.image = UIImage(named: "delete")
        action.backgroundColor = #colorLiteral(red: 0.9334464073, green: 0.38993752, blue: 0.2985897362, alpha: 1)

        return UISwipeActionsConfiguration(actions: [action])
    }
}

// MARK: - privates
private extension SubscriptionDetailViewController {
    func loadSubscription() {
        guard removingMemberIds.isEmpty else {
            toggleLoading(false)
            return
        }

        if subscription == nil {
            toggleLoading(true)
        }

        ApiProvider.default
            .request(Api.getSubscriptionDetail(id: subscriptionListItem.id))
            .response(Subscription.self, jsonDecoder: .appDefault) { [weak self] response in

                self?.toggleLoading(false)

                if let value = response.value {
                    self?.reload(subscription: value)
                } else {
                    self?.showError(response.error)
                }
            }
    }

    func showAlertRemovingAtIndexPath(_ indexPath: IndexPath) {

        guard let memberId = subscription?.members?[indexPath.section].id else { return }

        let alert = UIAlertController(title: L("subscription_remove_member_alert_title"),
                                      message: L("subscription_remove_member_alert_message"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L("subscription_remove_member_alert_cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: L("subscription_remove_member_alert_ok"), style: .destructive, handler: { _ in
            self.removeMemberId(memberId)
        }))

        present(alert, animated: true)
    }

    func removeMemberId(_ id: Int) {
        guard let section = subscription?.members?.firstIndex(where: { $0.id == id}) else { return }

        removingMemberIds.append(id)
        tableView.reloadRows(at: [IndexPath(item: 0, section: section)], with: .automatic)

        ApiProvider.default
            .request(Api.removeSubscriptionMember(subscriptionId: subscriptionListItem.id, memberId: id))
            .response { [weak self] response in
                if let error = response.error {
                    self?.showError(error)
                } else {
                    self?.handleMemberRemoved(id: id)
                }
            }
    }

    func toggleLoading(_ isLoading: Bool) {

        tableView.isHidden = isLoading

        if isLoading {
            loadingView.startAnimating()
        } else {
            tableView.refreshControl?.endRefreshing()
            loadingView.stopAnimating()
        }
    }

    func showError(_ error: Error?) {
        self.displayError(error)
    }

    func reload(subscription: Subscription) {
        self.subscription = subscription
        self.subscriptionListItem = subscription.listItem

        reloadBaseInfo()
        tableView.reloadData()
    }

    func reloadBaseInfo() {

        let df = DateFormatter()
        df.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMyyyy", options: 0, locale: .current)

        typeLabel.text = subscriptionListItem.name
        managerLabel.text = subscriptionListItem.subscriptionOwner ?? "-"
        occupancyLabel.text = "\(subscriptionListItem.currentMembers) / \(subscriptionListItem.totalMembers)"
        if let exp = subscriptionListItem.expireOn {
            expirationLabel.text = df.string(from: exp)
        } else {
            expirationLabel.text = "-"
        }

        let availableSlots = subscriptionListItem.totalMembers - subscriptionListItem.currentMembers
        if availableSlots > 0  {
            memberDescriptionLabel.text = String(format: L("subscription_detail_memberlist_available_description"), availableSlots)
            addMemberView.isHidden = false
        } else {
            memberDescriptionLabel.text = L("subscription_detail_memberlist_full_description")
            addMemberView.isHidden = true
        }
    }

    func handleMemberRemoved(id: Int) {
        guard let idx = subscription?.members?.firstIndex(where: { id == $0.id}) else {
            return
        }

        removingMemberIds.removeAll(where: { $0 == id })

        // locally update content
        subscription?.members?.remove(at: idx)
        subscription?.currentMembers -= 1

        subscriptionListItem = subscription?.listItem

        reloadBaseInfo()
        tableView.deleteSections(IndexSet(integer: idx), with: .automatic)
    }

    func cancelSubscription() {

        func toggleCanelSubscritionLoading(_ isLoading: Bool) {
            if isLoading {
                cancelLoadingView.startAnimating()
                cancelSubscriptionButton.isHidden = true
            } else {
                cancelLoadingView.stopAnimating()
                cancelSubscriptionButton.isHidden = false
            }
        }

        toggleCanelSubscritionLoading(true)
        ApiProvider.default.request(Api.cancelSubscription(id: subscriptionListItem.id))
            .response { [weak self] response in
                toggleCanelSubscritionLoading(false)
                if let error = response.error {
                    self?.displayError(error)
                } else {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
    }
}
