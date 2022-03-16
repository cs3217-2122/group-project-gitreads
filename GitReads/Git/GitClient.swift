//
//  GitClient.swift
//  GitReads

protocol GitClient {
    func getRepository(owner: String, name: String, ref: GitRef?) async -> Result<GitRepo, Error>
}
