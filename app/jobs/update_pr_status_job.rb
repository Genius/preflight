class UpdatePrStatusJob < ApplicationJob
  retry_on Octokit::Error, attempts: 15

  def perform(installation_id, repo, pr_number)
    client = GithubClient.for_installation(installation_id)
    pr = client.pull_request(repo.github_full_name, pr_number)

    merge_sha = pr[:merge_commit_sha]
    body = pr[:body]

    body_results = MarkdownChecklistParser.parse(body)

    status = :success
    desc = 'Ready for takeoff!'

    if body_results[:unchecked] > 0
      status = :pending
      desc = 'One or more boxes have yet to be checked.'
    end

    client.create_status(repo.github_full_name, merge_sha, status, context: 'Preflight Checklist', description: desc)
  end
end
