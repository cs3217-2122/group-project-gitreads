//
//  ErrorHandler.swift
//  Peggle

import SwiftUI

/// Lightweight set of structs and classes to simplify error handling logic in the view.
/// Any calls that throw errors can be wrapped with a function to automatically show
/// the error as an alert.
///
/// - Usage:
/// First, create the `ErrorHandler` in any view as a instance variable. It is a tuple that
/// includes a view modifier and functions that can wrap any calls that may throw errors.
/// Next, add the modifier to a view body via `.withErrorHandler(errorHandler)`.
/// Finally, wrap any statement that throws with `handler.doWithErrorHandling`. For
/// async statements, use the `handler.doAsyncWithErrorHandling` variant.  Any
/// error that is thrown will then show up as an alert.

typealias ErrorHandler = (
    modifier: ErrorHandlerModifier,
    doWithErrorHandling: (() throws -> Void) -> Void,
    doAsyncWithErrorHandling: (() async throws -> Void) async -> Void
)

func makeErrorHandler(debug: Bool = false) -> ErrorHandler {
    let errorWrapper = ErrorWrapper(debug: debug)
    let modifier = ErrorHandlerModifier(errorWrapper: errorWrapper, debug: debug)

    func doWithErrorHandling(action: () throws -> Void) {
        do {
            try action()
        } catch {
            errorWrapper.setError(error)
        }
    }

    func doAsyncWithErrorHandling(action: () async throws -> Void) async {
        do {
            try await action()
        } catch {
            errorWrapper.setError(error)
        }
    }

    return (modifier, doWithErrorHandling, doAsyncWithErrorHandling)
}

/// View modifier to help with handling errors.
struct ErrorHandlerModifier: ViewModifier {

    @ObservedObject fileprivate var errorWrapper: ErrorWrapper
    let debug: Bool

    fileprivate init(errorWrapper: ErrorWrapper, debug: Bool = false) {
        self.errorWrapper = errorWrapper
        self.debug = debug
    }

    func body(content: Content) -> some View {
        let error = errorWrapper.error
        content
            .alert(error?.localizedFailureReason ?? "Error", isPresented: $errorWrapper.presentAlert) {
                if let suggestion = error?.localizedRecoverySuggestion {
                    Button(suggestion) {}
                }
            } message: {
                if let description = error?.localizedDescription {
                    Text(description)
                }
            }
    }
}

extension View {
    func withErrorHandler(_ errorHandler: ErrorHandler) -> some View {
        modifier(errorHandler.modifier)
    }
}

private class ErrorWrapper: ObservableObject {
    /// Casting unknown errors to NSError allows us to handle `Error`, `LocalizedError`,
    /// and `NSError`. More information here: http://www.figure.ink/blog/2021/7/18/practical-localized-error-values
    @Published var error: NSError?
    @Published var presentAlert = false

    let debug: Bool

    init(debug: Bool = false) {
        self.debug = debug
    }

    func setError(_ error: Error) {
        DispatchQueue.main.sync {
            self.error = error as NSError
            presentAlert = true
        }

        if debug {
            print("Error: \(self.error.debugDescription)")
        }
    }
}
