//
//  SubscriptionsViewController.swift
//  WorldMedicalCard
//
//  Created by Apphuset on 03/06/2022.
//

import UIKit
import SafariServices

final class SubscriptionsViewController: UIViewController {
    @IBOutlet weak var noSubscriptionLabel: UILabel!
    @IBOutlet weak var noSubscriptionDescriptionLabel: UILabel!
    @IBOutlet weak var noSubscriptionView: UIView!
    @IBOutlet weak var subscribeNowButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subscribeMembershipLabel: UILabel!
    @IBOutlet var emptyView: UIView!
    @IBOutlet var loadingView: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    private let cellReuseId = "SubscriptionCell"

    private var ownerSubscriptions = [SubscriptionListItem]()
    private var memberSubscriptions = [SubscriptionListItem]()
    
    var user: UserProfile!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SubscriptionTableViewCell", bundle: nil),
                           forCellReuseIdentifier: cellReuseId)

        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = refresher

        subscribeMembershipLabel.attributedText = NSAttributedString(
            string: L("subscription_overview_text_subscribe"),
            attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])

        tableView.isHidden = true
        emptyView.isHidden = true

        navigationItem.backButtonTitle = " "
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        noSubscriptionView.alpha = 0
        loadSubscriptions()
    }
    //MARK: - Setup View
    func setupView() {
        title = L("subscription_overview_title")
        noSubscriptionLabel.text = L("no_subscription_title")
        noSubscriptionDescriptionLabel.text = L("no_subscription_description")
        subscribeNowButton.setTitle(L("subscribe_button"), for: .normal)
        // hide content for the first loading
        titleLabel.text = String(format: L("subscription_overview_subtitle"), subscriptionsCount)
        subscribeMembershipLabel.isHidden = true
    }

    // MARK: - Actions
    @IBAction func didPressSubscribeNow(_ sender: Any) {
        let sf = SFSafariViewController(url: Environment.subscriptionUrl)
        present(sf, animated: true)
    }
    
    @IBAction func addSubscriptionTapped() {
        let sf = SFSafariViewController(url: Environment.subscriptionUrl)
        present(sf, animated: true)
    }

    @objc func pullToRefresh() {
        loadSubscriptions()
    }
}

extension SubscriptionsViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? ownerSubscriptions.count : memberSubscriptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let isOwner = indexPath.section == 0
        let item = isOwner ? ownerSubscriptions[indexPath.item] : memberSubscriptions[indexPath.item]

        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId, for: indexPath) as! SubscriptionTableViewCell
        cell.fill(subscription: item, isOwner: isOwner)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isOwner = indexPath.section == 0
        guard isOwner else {
            let alert = UIAlertController(
                title: L("subscription_overview_item_selected_alert_not_owner_title"),
                message: L("subscription_overview_item_selected_alert_not_owner_message"),
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: L("ok_button_title"), style: .cancel))
            present(alert, animated: true)

            return
        }

        let detail = SubscriptionDetailViewController.instantiateFrom(storyboard: .subscription)
        detail.subscriptionListItem = ownerSubscriptions[indexPath.item]
        navigationController?.pushViewController(detail, animated: true)
    }
}

// MARK: - privates
private extension SubscriptionsViewController {

    var subscriptionsCount: Int {
        ownerSubscriptions.count + memberSubscriptions.count
    }

    var isSubscriptionEmpty: Bool {
        ownerSubscriptions.isEmpty && memberSubscriptions.isEmpty
    }

    func loadSubscriptions() {

        if isSubscriptionEmpty {
            toggleLoading(true)
        }

        var ownerItems = [SubscriptionListItem]()
        var memberItems = [SubscriptionListItem]()
        var error: Error?

        let taskGroup = DispatchGroup()

        taskGroup.enter()
        ApiProvider.default
            .request(Api.getOwnerSubscriptions)
            .response([SubscriptionListItem].self, jsonDecoder: .appDefault) { response in

                if let value = response.value {
                    ownerItems = value
                } else {
                    error = response.error
                }

                taskGroup.leave()
            }

        taskGroup.enter()
        ApiProvider.default
            .request(Api.getMemberSubscriptions)
            .response([SubscriptionListItem].self, jsonDecoder: .appDefault) { response in

                if let value = response.value {
                    memberItems = value
                } else {
                    error = response.error
                }

                taskGroup.leave()
            }

        taskGroup.notify(queue: .main) { [weak self] in
            self?.toggleLoading(false)
            if let error = error, error._code == NSURLErrorTimedOut {
                self?.alert(title: L("subscription_time_out_dialog_title"),
                      message: L("subscription_time_out_dialog_message"),
                      ok: nil)
            }
            guard let user = self?.user else { return }
            if user.isActiveSubscription == false {
                self?.alert(title: L("subscription_not_active_dialog_title"),
                            message: L("subscription_not_active_dialog_message"),
                            ok: { [weak self] in
                    self?.showNoSubscriptionView()
                })
                return
            }
            if let error = error {
                self?.showError(error)
            } else {
                self?.reload(ownerSubscriptions: ownerItems, memberSubscriptions: memberItems)
            }
        }
    }
    //Bottom view
    func showNoSubscriptionView() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear) { [unowned self] in
            self.noSubscriptionView.alpha = 1.0
        } completion: { _ in }
    }

    func toggleLoading(_ isLoading: Bool) {
        if isLoading {
            loadingView.startAnimating()
        } else {
            tableView.refreshControl?.endRefreshing()
            loadingView.stopAnimating()
        }
    }

    func showError(_ error: Error?) {
        guard isSubscriptionEmpty else { return }
        self.displayError(error)
    }

    func reload(ownerSubscriptions: [SubscriptionListItem], memberSubscriptions: [SubscriptionListItem]) {

        self.ownerSubscriptions = ownerSubscriptions
        self.memberSubscriptions = memberSubscriptions

        let isEmpty = isSubscriptionEmpty
        emptyView.isHidden = !isEmpty
        subscribeMembershipLabel.isHidden = isEmpty
        tableView.isHidden = isEmpty

        titleLabel.text = String(format: L("subscription_overview_subtitle"), subscriptionsCount)
        tableView.reloadData()
    }
}
