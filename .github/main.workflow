workflow "Fast prototype" {
  on = "push"
  resolves = ["Create PR"]
}

action "Create PR" {
  uses = "./"
  secrets = ["GITHUB_TOKEN"]
  args = ".head_commit.message .*#pr.*"
}
