//
//  RepoService.swift
//  GitReads

class RepoService {

    let gitClient: GitClient
    let parser: Parser

    init(gitClient: GitClient, parser: Parser) {
        self.gitClient = gitClient
        self.parser = parser
    }

    func getRepository(owner: String, name: String, ref: GitRef? = nil) async -> Result<Repo, Error> {
        await gitClient
            .getRepository(owner: owner, name: name, ref: ref)
            .asyncFlatMap { await parser.parse(gitRepo: $0) }
    }

}
