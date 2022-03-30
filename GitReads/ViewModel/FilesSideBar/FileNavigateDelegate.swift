//
//  FileNavigateDelegate.swift
//  GitReads

protocol FileNavigateDelegate: AnyObject {
    func navigateTo(_ option: FileNavigateOption)
}
