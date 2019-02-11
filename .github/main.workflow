workflow "New workflow" {
  on = "push"
  resolves = ["Create PR"]
}

action "Create PR" {
  uses = "./"
  arguments = ".head_commit.message #pr"
  secrets = ["GITHUB_TOKEN"]
}
