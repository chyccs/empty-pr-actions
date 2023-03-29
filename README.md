# Empty Pull-Request Actions

### Background
Before starting work on a reported issue, a `pull-request` can be created arbitrarily by using the `--allow-empty` option of the `git commit` command.

### Usage
* Use `issue_comment` event trigger

```yaml
on:
  issue_comment:
    types: [created]
  
permissions:
  contents: write
  issues: write
  pull-requests: write

jobs:
  create-pr:
    runs-on: ubuntu-latest
    if: ${{ !github.event.issue.pull_request }}
    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Create PR when issue_comment event occured
        if: ${{ startsWith(github.event.comment.body, '@pr ') }}
        uses: chyccs/empty-pr-actions@master
        with:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

* Use `issues` event trigger

```yaml
on:
  issues:
    types: [opened, edited]
  
permissions:
  contents: write
  issues: write
  pull-requests: write

jobs:
  create-pr:
    runs-on: ubuntu-latest
    if: ${{ !github.event.issue.pull_request }}
    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Create PR when issues was created
        uses: chyccs/empty-pr-actions@master
        with:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

<!-- | Param | Desc | Type | Required |
| -- | -- | -- | -- |
| GITHUB_TOKEN | [Token explain](#token) | string | ✖ |
| pull_request_name | The number of issue. When not input, it will be obtained from the trigger event | number | ✖ |
| assignees | Designated person. No operation when no input or empty character | string | ✖ |
| random-to | When set, it will be randomly selected in assignees | number | ✖ | -->
