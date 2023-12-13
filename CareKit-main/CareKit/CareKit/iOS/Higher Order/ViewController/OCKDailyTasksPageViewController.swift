/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3. Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
#if !os(watchOS)

import CareKitStore
import CareKitUI
import Combine
import SwiftUI
import UIKit

/// Handles events related to an `OCKDailyTasksPageViewController`.
public protocol OCKDailyTasksPageViewControllerDelegate: OCKTaskViewControllerDelegate {

    /// Return a view controller to display for the given task and events.
    /// - Parameters:
    ///   - viewController: The view controller displaying the returned view controller.
    ///   - task: The task to be displayed by the returned view controller.
    ///   - events: The events to be displayed by the returned view controller.
    ///   - eventQuery: The query used to retrieve the events for the task.
    func dailyTasksPageViewController(_ viewController: OCKDailyTasksPageViewController, viewControllerForTask task: OCKAnyTask,
                                      events: [OCKAnyEvent], eventQuery: OCKEventQuery) -> UIViewController?
}

/// Displays a calendar page view controller in the header, and a collection of tasks
/// in the body. The tasks are automatically queried based on the selection in the calendar.
open class OCKDailyTasksPageViewController: OCKDailyPageViewController {

    private let emptyLabelMargin: CGFloat = 10

    // MARK: Properties

    /// If set, the delegate will receive callbacks when important events happen at the task view controller level.
    public weak var tasksDelegate: OCKDailyTasksPageViewControllerDelegate?

    // MARK: - Methods

    private func fetchTasks(for date: Date, andPopulateIn listViewController: OCKListViewController) {
        let taskQuery = OCKTaskQuery(for: date)
        storeManager.store.fetchAnyTasks(query: taskQuery, callbackQueue: .main) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error): self.delegate?.dailyPageViewController(self, didFailWithError: error)
            case .success(let tasks):

                // Show an empty label if there are no tasks
                guard !tasks.isEmpty else {
                    listViewController.listView.stackView.spacing = self.emptyLabelMargin
                    let emptyLabel = OCKEmptyLabel(textStyle: .headline, weight: .semibold)
                    listViewController.appendView(emptyLabel, animated: false)
                    return
                }

                // Aggregate the view controllers returned after fetching the events
                let group = DispatchGroup()
                var viewControllers: [UIViewController] = []
                tasks.forEach {
                    group.enter()
                    self.viewController(forTask: $0, fromQuery: taskQuery) { viewController in
                        viewController.map { viewControllers.append($0) }
                        group.leave()
                    }
                }

                // Add the view controllers to the view
                group.notify(queue: .main) {
                    viewControllers.forEach { listViewController.appendViewController($0, animated: false) }
                }
            }
        }
    }

    // Fetch events and return a view controller to display the data
    private func viewController(
        forTask task: OCKAnyTask,
        fromQuery query: OCKTaskQuery,
        result: @escaping (UIViewController?) -> Void) {

        guard let dateInterval = query.dateInterval else { fatalError("Task query should have a set date") }
        let eventQuery = OCKEventQuery(dateInterval: dateInterval)
        self.storeManager.store.fetchAnyEvents(taskID: task.id, query: eventQuery, callbackQueue: .main) { [weak self] fetchResult in
            guard let self = self else { return }
            switch fetchResult {
            case .failure(let error): self.delegate?.dailyPageViewController(self, didFailWithError: error)
            case .success(let events):
                let viewController =
                    self.tasksDelegate?.dailyTasksPageViewController(self, viewControllerForTask: task, events: events, eventQuery: eventQuery) ??
                    self.dailyTasksPageViewController(self, viewControllerForTask: task, events: events, eventQuery: eventQuery)
                result(viewController)
            }
        }
    }

    /* CUSTOM: Override del controller principale, per la gestione della disattivazione dei task futuri e l'aggiunta
     della situazione per la quale non ci sono task da completare*/
    override open func dailyPageViewController(
        _ dailyPageViewController: OCKDailyPageViewController,
        prepare listViewController: OCKListViewController,
        for date: Date) {
            
            let isFuture = Calendar.current.compare(
            date,
            to: Date(),
            toGranularity: .day) == .orderedDescending
            
            self.fetchTasks(on: date){ tasks in
                
                /*Se non ci sono task per la data giornaliera, mostra la label custom*/
                guard !tasks.isEmpty else {
                    listViewController.listView.stackView.spacing = self.emptyLabelMargin
                    let emptyLabel = OCKEmptyLabel(textStyle: .headline, weight: .semibold)
                    listViewController.appendView(emptyLabel, animated: false)
                    return
                }
                                
                                /* per ogni task fetchato, se la sua data di schedulazione è successiva a quella corrente,
                                 viene disabilitata l'interazione e modificato il suo alpha */
                                tasks.compactMap {

                                    let card = self.taskViewController(for: $0, on: date)
                                    card?.view.isUserInteractionEnabled = !isFuture
                                    card?.view.alpha = isFuture ? 0.4 : 1.0

                                    return card

                                }.forEach {
                                    listViewController.appendViewController($0, animated: false)
                                }
            }

    }
    
    //CUSTOM:  TaskViewController definito per la gestione dei task nel controller calendar principale
    private func taskViewController(
            for task: OCKAnyTask,
            on date: Date) -> UIViewController? {

            switch task.id {
                
            case task.id:
                let task = OCKSimpleTaskViewController(taskID: task.id, eventQuery: OCKEventQuery(for: date), storeManager: storeManager)
                return task
            default:
                return nil
            }
        }
    
    /* CUSTOM: Fetch dei task definita per la gestione del controller su cui è stato definito l'override*/
    private func fetchTasks(
            on date: Date,
            completion: @escaping([OCKAnyTask]) -> Void) {

            var query = OCKTaskQuery(for: date)
            query.excludesTasksWithNoEvents = true

            storeManager.store.fetchAnyTasks(
                query: query,
                callbackQueue: .main) { result in

                switch result {

                case .failure:
                    print("Failed to fetch tasks for date \(date)")
                    completion([])

                case let .success(tasks):
                    completion(tasks)
                }
            }
        }
    
    

    // MARK: - OCKDailyTasksPageViewControllerDelegate

    open func dailyTasksPageViewController(
        _ viewController: OCKDailyTasksPageViewController,
        viewControllerForTask task: OCKAnyTask,
        events: [OCKAnyEvent],
        eventQuery: OCKEventQuery) -> UIViewController? {

        // If the task is linked to HealthKit, show a view geared towards displaying HealthKit data
        if #available(iOS 14, *), task is OCKHealthKitTask {
            let controller = OCKNumericProgressTaskController(storeManager: storeManager)
            controller.setViewModelAndObserve(events: events, query: eventQuery)
            return NumericProgressTaskView(controller: controller)
                .hosted()

        // Show the button log if the task does not impact adherence
        } else if !task.impactsAdherence {
            let taskViewController = OCKButtonLogTaskViewController(controller: .init(storeManager: self.storeManager), viewSynchronizer: .init())
            taskViewController.controller.setViewModelAndObserve(events: events, query: eventQuery)
            return taskViewController

        // Show the simple if there is only one event. Visually this is the best style for a single event.
        } else if events.count == 1 {
            let taskViewController = OCKSimpleTaskViewController(controller: .init(storeManager: self.storeManager), viewSynchronizer: .init())
            taskViewController.controller.setViewModelAndObserve(events: events, query: eventQuery)
            return taskViewController

        // Else default to the grid
        } else {
            let taskViewController = OCKGridTaskViewController(controller: .init(storeManager: self.storeManager), viewSynchronizer: .init())
            taskViewController.controller.setViewModelAndObserve(events: events, query: eventQuery)
            return taskViewController
        }
    }
}

private class OCKEmptyLabel: OCKLabel {
    override init(textStyle: UIFont.TextStyle, weight: UIFont.Weight) {
        super.init(textStyle: textStyle, weight: weight)
        text = loc("Nessun task da completare, torna domani!") /* Modifica stringa di visualizzazione in assenza di task da completare */
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func styleDidChange() {
        super.styleDidChange()
        textColor = style().color.label
    }
}

private extension View {
    func hosted() -> UIHostingController<Self> {
        let viewController = UIHostingController(rootView: self)
        viewController.view.backgroundColor = .clear
        return viewController
    }
}
#endif



